#!/bin/bash
set -e -u

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd . && pwd -P )"
cd "${THIS_DIR}"

N_RUNS=1

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--number)
      N_RUNS="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      echo "Unknown option $1"
      echo "Please use -n (--number) <N> in order to specify the number of runs you want to execute."
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

echo "Dirichlet Participant: running "${N_RUNS}" simulation(s) in the loop."
echo ""
for ((i=1; i <= "${N_RUNS}"; i++)) ; do
    python3 heat.py -d
done
