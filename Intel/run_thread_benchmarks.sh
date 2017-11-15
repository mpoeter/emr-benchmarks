for r in "LFRC-padded" "EBR" "NEBR" "QSBR" "static-HPBR" "stamp" ; do
	for b in "list --modify-fraction 0.8" "list --modify-fraction 0.2" "queue" ; do
		for thread in 1 2 4 8 16 24 32 48 64 80 96 128 160 ; do
			../benchmark --reclaimer $r --threads $thread --benchmark $b --csv thread_results.csv --trials 30 --runtime 8000
		done
	done
done

# hash_map benchmark requires dynamic-HPBR
for r in "LFRC-padded-20" "EBR" "NEBR" "QSBR" "dynamic-HPBR" "stamp" ; do
	for thread in 1 2 4 8 16 24 32 48 64 80 96 128 160 ; do
		../benchmark --reclaimer $r --threads $thread --benchmark "hash_map" --csv thread_results.csv --trials 30 --runtime 8000
	done
done
