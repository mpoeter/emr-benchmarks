for b in "guard_ptr" "list --modify-fraction 0.0" "list --modify-fraction 1.0" "queue" "hash_map" ; do
	for r in "LFRC" "static-HPBR" "EBR" "NEBR" "QSBR" "stamp" "DEBRA"; do
		../benchmark --reclaimer $r --threads 1 --benchmark $b --csv base_cost_results.csv --trials 30 --runtime 10000
	done
done
