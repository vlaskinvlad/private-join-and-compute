#! /bin/bash


home_repo=${HOME}/repo/private-join-and-compute
#sizes=( 100 500 1000 2000 3000 5000 8000 10000 14000 18000 20000 25000 30000 40000 50000 60000 70000 80000 90000 100000 150000 200000 300000 400000 500000 1000000)
sizes=( 100 1000 10000)
ips=( '10.64.26.155' '10.64.44.125')

mkdir -p  ${home_repo}/perftest/certs 
cd ${home_repo}/perftest/certs
`../../certs/gen-certs.sh`


for size in "${sizes[@]}"
do
    echo "Generating dummy files for size ${size}"
    cd ${home_repo}

    docker rm -f ptest-gen || true

    docker run -v ${home_repo}/perftest/dummy:/tmp \
    --name ptest-gen \
    vlaskinvlad/pjc bazel-bin/generate_dummy_data \
    --server_data_file=/tmp/dummy_server_data_${size}.csv \
    --client_data_file=/tmp/dummy_client_data_${size}.csv \
    --server_data_size=${size} --client_data_size=${size} \
    --intersection_size=$(( size / 2 ))
    # echo "1. cleaning up test data"
    # make clean-test-data
    # echo "2. generating test data sample size: ${size}"
    # make etl-secret-lift-simulate SAMPLE_SIZE=${size}
    # cd ${home_sm}   

done

for ip in "${ips[@]}"
do
    echo "Syncing: ${ip}"
    rsync -azP perftest/dummy ubuntu@${ip}:/home/ubuntu
    rsync -azP perftest/certs ubuntu@${ip}:/home/ubuntu
done

cd ${home_repo}

for ip in "${ips[@]}"
do
    echo "Syncing static scripts: ${ip}"        
    rsync perftest/stats.sh ubuntu@${ip}:/home/ubuntu/stats.sh    
    # rsync etc/lift-tutorial/ptest.sh ubuntu@${ip}:/home/ubuntu/ptest.sh  
done



# cd ${home_smw}

# for ip in "${ips[@]}"
# do
#     echo "Syncing static scripts: ${ip}"    
#     rsync etc/lift-tutorial/NetworkData_AWS.txt ubuntu@${ip}:/home/ubuntu/NetworkData.txt
#     rsync etc/lift-tutorial/stats.sh ubuntu@${ip}:/home/ubuntu/stats.sh
#     rsync etc/lift-tutorial/ptest.sh ubuntu@${ip}:/home/ubuntu/ptest.sh  
# done
