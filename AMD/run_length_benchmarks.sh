for r in "LFRC-padded" "LFRC-padded-20" "static-HPBR" "EBR" "NEBR" "QSBR" "stamp" ; do
	for threads in 1 32 ; do
		for workload in "0.0" "0.5" ; do
			for length in 0 1 5 10 25 50 100 ; do                  
				../benchmark --reclaimer $r --threads $threads --benchmark list --modify-fraction $workload --elements $length --csv length_results.csv --trials 30 --runtime 8000
			done
		done
	done
done
