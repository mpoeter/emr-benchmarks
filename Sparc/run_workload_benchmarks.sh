export LD_PRELOAD=libjemalloc.so
for r in "LFRC-padded-20" "LFRC-padded" "static-HPBR" "EBR" "NEBR" "QSBR" "stamp" "DEBRA" ; do
	for threads in 1 32 ; do
		for elems in 1 25 ; do
			for workload in "0" "0.01" "0.02" "0.05" "0.1" "0.25" "0.50" "0.75" "1"  ; do
				../benchmark --reclaimer $r --threads $threads --benchmark list --elements $elems --modify-fraction $workload --csv workload_results.csv --trials 30 --runtime 8000
			done
		done
	done
done
