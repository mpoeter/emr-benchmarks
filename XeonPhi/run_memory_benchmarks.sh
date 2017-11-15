for r in "LFRC-padded-20" "dynamic-HPBR" "EBR" "NEBR" "QSBR" "stamp" ; do
	for benchmark in "hash_map" "queue" "list --modify-fraction 0.2" "list --modify-fraction 0.8" ; do
		for i in {1..20} ; do
			../benchmark --reclaimer $r --threads 244 --benchmark $benchmark --csv memory_results.csv --trials 5 --runtime 8000 --memory-samples 48
		done
	done
done
