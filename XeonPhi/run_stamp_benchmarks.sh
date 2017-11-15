for b in "list --modify-fraction 0.8" "list --modify-fraction 0.2" "queue" "hash_map" "guard_ptr" ; do
	for thread in 1 2 4 8 16 24 32 48 64 80 96 128 160 192 244 ; do
		../benchmark --reclaimer stamp --threads $thread --benchmark $b --csv stamp_results.csv --trials 30 --runtime 8000
	done
done
