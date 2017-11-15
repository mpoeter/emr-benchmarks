for b in "list --modify-fraction 0.8" "list --modify-fraction 0.2" "queue" "hash_map" ; do
	for r in "LFRC" "LFRC-unpadded-20" "LFRC-padded" "LFRC-padded-20" ; do
		for thread in 1 2 4 8 16 24 32 48 ; do
			../benchmark --reclaimer $r --threads $thread --benchmark $b --csv LFRC_results.csv --trials 30 --runtime 8000
		done
	done
done
