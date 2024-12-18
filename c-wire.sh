#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 <data_file> <station_type> <consumer_type> [central_id]"
    echo
    echo "Arguments:"
    echo "  data_file       Chemin vers le fichier CSV d'entrée (obligatoire)"
    echo "  station_type    Type de station à traiter (obligatoire):"
    echo "                  hvb, hva, lv"
    echo "  consumer_type   Type de consommateur à traiter (obligatoire):"
    echo "                  comp, indiv, all"
    echo "                  Remarque : hvb all, hvb indiv, hva all, hva indiv ne sont pas autorisés."
    echo "  central_id      Optionnel : Filtrer les résultats par ID central."
    echo
    echo "Options:"
    echo "  -h              Afficher ce message d'aide."
    echo
    echo "Examples:"
    echo "  $0 input/data.csv lv all"
    echo "  $0 input/data.csv hva comp 1"
    exit 0
}

# Check if help is requested
if [[ "$1" == "-h" ]]; then
    show_help
fi

# Validate the number of arguments
if [[ $# -lt 3 ]]; then
    echo "Erreur : Arguments manquants."
    show_help
fi

# Assign arguments to variables
DATA_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3
CENTRAL_ID=${4:-"all"}  # Default to "all" if not provided

# Validate input file
if [[ ! -f "$DATA_FILE" ]]; then
    echo "Erreur : Fichier d'entrée '$DATA_FILE' introuvable."
    exit 1
fi

# Validate station type
if [[ "$STATION_TYPE" != "hvb" && "$STATION_TYPE" != "hva" && "$STATION_TYPE" != "lv" ]]; then
    echo "Erreur : Type de station invalide '$STATION_TYPE'. Doit être l'un des suivants : hvb, hva, lv.."
    exit 1
fi

# Validate consumer type
if [[ "$CONSUMER_TYPE" != "comp" && "$CONSUMER_TYPE" != "indiv" && "$CONSUMER_TYPE" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide '$CONSUMER_TYPE'. Doit être l'un des suivants : comp, indiv, all.."
    exit 1
fi

# Handle invalid combinations of station and consumer types
if { [[ "$STATION_TYPE" == "hvb" || "$STATION_TYPE" == "hva" ]] && [[ "$CONSUMER_TYPE" == "all" || "$CONSUMER_TYPE" == "indiv" ]]; }; then
    echo "Erreur : Type de consommateur '$CONSUMER_TYPE' n'est pas autorisé avec le type de station '$STATION_TYPE'."
    exit 1
fi

# Create temporary and output directories if they don't exist
mkdir -p tmp tests graphs

# Filter data
FILTERED_FILE="tmp/filtered_data.csv"
awk -F ";" -v station="$STATION_TYPE" -v consumer="$CONSUMER_TYPE" -v central="$CENTRAL_ID" '
BEGIN { OFS = ":" }
{
    # Filter data based on station and consumer type
    if (central == "all" || $1 == central) {
        if (station == "hvb" && consumer == "comp" && $2 != "-") {
            print $2, $7, $8
        } else if (station == "hva" && consumer == "comp" && $3 != "-") {
            print $3, $7, $8
        } else if (station == "lv" && consumer == "comp" && $4 != "-" && ($5 != "-" || $7 != "-")) {
                print $4, $7, $8
        }else if (station == "lv" && consumer == "indiv" && $4 != "-" && ($6 != "-"|| $7 != "-")) {
                print $4, $7, $8
        }else if (station == "lv" && consumer == "all" && $4 != "-") {
                print $4, $7, $8
        }
    }
    # Debugging: Print all lines processed
    print "DEBUG: Line processed: " $0 > "/dev/stderr"
}' "$DATA_FILE" > "$FILTERED_FILE"

# Check if filtered file is empty
if [[ ! -s "$FILTERED_FILE" ]]; then
    echo "Erreur : Aucune donnée trouvée correspondant aux filtres."
    exit 1
fi

# Prepare output file name
OUTPUT_FILE="tests/${STATION_TYPE}_${CONSUMER_TYPE}"
if [[ "$CENTRAL_ID" != "all" ]]; then
    OUTPUT_FILE="${OUTPUT_FILE}_${CENTRAL_ID}"
fi
OUTPUT_FILE="${OUTPUT_FILE}.csv"

# Compile the C program if necessary
cd codeC
if [[ ! -f main ]]; then
    echo "Compilation du programme C..."
    make
    if [[ $? -ne 0 ]]; then
        echo "Erreur : La compilation a échoué."
        exit 1
    fi
fi
cd ..


# Function to generate minmax.csv and plot a graph
generate_lv_minmax_graph() {
    local output_file=$1
    local minmax_file=$2
    local graph_file=$3

    echo "StationID:Capacity:Consumption" > "$minmax_file"

    # Extract the 10 LV stations with the most consumption
    tail -n +2 "$output_file" | sort -t: -k3nr | head -n 10 >> "$minmax_file"

    # Extract the 10 LV stations with the least consumption
    tail -n +2 "$output_file" | sort -t: -k3n | head -n 10 >> "$minmax_file"

    echo "Minmax data saved to: $minmax_file"

    # Prepare data for GnuPlot by replacing ':' with spaces
    sed 's/:/ /g' "$minmax_file" > tmp/temp_file.txt

    # Generate GnuPlot script
    local gnuplot_script="tmp/lv_minmax_plot.gnuplot"
    cat <<EOF > "$gnuplot_script"
set terminal png size 1000,700
set output '$graph_file'
set title "Top and Bottom 10 LV Stations by Capacity and Consumption"
set xlabel "Station ID"
set ylabel "Energy (kWh)"
set grid ytics
set key inside top right
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.8
set xtics rotate by -45
set palette maxcolors 2
set border lw 1

# Plot data from the processed file
plot "< cat tmp/temp_file.txt" using 2:xtic(1) title "Capacity" lc rgb "#00b300", \
     "< cat tmp/temp_file.txt" using 3:xtic(1) title "Consumption" lc rgb "#ff3333"
EOF

    # Execute GnuPlot script
    gnuplot "$gnuplot_script"
    echo "Graph generated: $graph_file"
}


# Special handling for lv all
if [[ "$STATION_TYPE" == "lv" && "$CONSUMER_TYPE" == "all" ]]; then
    OUTPUT_FILE="tests/lv_all.csv"
    if [[ "$CENTRAL_ID" != "all" ]]; then
        OUTPUT_FILE="tests/lv_all_${CENTRAL_ID}.csv"
    fi

    echo "Traitement de lv all avec l'ID central '$CENTRAL_ID'..."
    ./codeC/main "$FILTERED_FILE" "$OUTPUT_FILE"  "$STATION_TYPE"

    # Generate graph only for lv all
    MINMAX_FILE="tests/lv_all_minmax.csv"
    if [[ "$CENTRAL_ID" != "all" ]]; then
        MINMAX_FILE="tests/lv_all_minmax_${CENTRAL_ID}.csv"
    fi

    
    # Generate graph only for lv all
    MINMAX_FILE="tests/lv_all_minmax.csv"
    GRAPH_FILE="graphs/lv_all_minmax.png"

    if [[ "$CENTRAL_ID" != "all" ]]; then
        MINMAX_FILE="tests/lv_all_minmax_${CENTRAL_ID}.csv"
        GRAPH_FILE="graphs/lv_all_minmax_${CENTRAL_ID}.png"
    fi

    generate_lv_minmax_graph "$OUTPUT_FILE" "$MINMAX_FILE" "$GRAPH_FILE"
    
fi

# Execute the C program for other cases
if [[ "$STATION_TYPE" != "lv" || "$CONSUMER_TYPE" != "all" ]]; then
    ./codeC/main "$FILTERED_FILE" "$OUTPUT_FILE" "$STATION_TYPE"
    echo "Traitement terminé. Résultats enregistrés dans : $OUTPUT_FILE."
fi