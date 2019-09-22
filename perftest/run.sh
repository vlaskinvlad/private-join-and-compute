 # server
 docker run -v $(pwd)/dummy:/tmp \
 -v $(pwd)/certs:/opt/PRIVATE-JOIN-AND-COMPUTE/certs \
 -p 10501:10501 --add-host="machine1:0.0.0.0" \
 vlaskinvlad/pjc bazel-bin/server \
 --server_data_file=/tmp/dummy_server_data_10000.csv \
 --message_size=12342134 --compression_level=2 --port=machine1:10501


#client
 docker run -v $(pwd)/dummy:/tmp \
 -v $(pwd)/certs:/opt/PRIVATE-JOIN-AND-COMPUTE/certs \
 --add-host="machine1:10.64.26.155"  \
 vlaskinvlad/pjc bazel-bin/client \
 --client_data_file=/tmp/dummy_client_data_10000.csv --port machine1:10501

