/*
 * Copyright 2019 Google Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <thread>  // NOLINT

#include "gflags/gflags.h"

#include "include/grpc/grpc_security_constants.h"
#include "include/grpcpp/grpcpp.h"
#include "include/grpcpp/security/server_credentials.h"
#include "include/grpcpp/server_builder.h"
#include "include/grpcpp/server_context.h"
#include "include/grpcpp/support/status.h"
#include "data_util.h"
#include "server_impl.h"
#include "private_join_and_compute.grpc.pb.h"
#include "private_join_and_compute_rpc_impl.h"
#include "protocol_server.h"
#include "absl/memory/memory.h"
#include "timer.h"


DEFINE_string(port, "0.0.0.0:10501", "Port on which to listen");
DEFINE_string(server_data_file, "",
              "The file from which to read the server database.");

DEFINE_int32(message_size, 124194304, "Bytes max message size");
DEFINE_uint32(compression_level, 3, "Compression level 0 no compression, 1 low, 2 med");


void
read ( const std::string& filename, std::string& data )
{
        std::ifstream file ( filename.c_str (), std::ios::in );
	if ( file.is_open() )
	{
		std::stringstream ss;
		ss << file.rdbuf();

		file.close();

		data = ss.str();
	}
	return;
}


int RunServer() {
  std::cout << "Server: loading data... " << std::endl;
  auto t_total = std::unique_ptr<Timer>(new Timer);
  
  auto maybe_server_identifiers =
      ::private_join_and_compute::ReadServerDatasetFromFile(FLAGS_server_data_file);
  if (!maybe_server_identifiers.ok()) {
    std::cerr << "RunServer: failed " << maybe_server_identifiers.status()
              << std::endl;
    return 1;
  }

  ::private_join_and_compute::Context context;
  std::unique_ptr<::private_join_and_compute::ProtocolServer> server =
      absl::make_unique<::private_join_and_compute::PrivateIntersectionSumProtocolServerImpl>(
          &context, std::move(maybe_server_identifiers.ValueOrDie()));
  ::private_join_and_compute::PrivateJoinAndComputeRpcImpl service(std::move(server));

  ::grpc::ServerBuilder builder;
  // Consider grpc::SslServerCredentials if not running locally.

  std::string key;
	std::string cert;
	std::string root;

  read ( "certs/server.crt", cert );
	read ( "certs/server.key", key );
	read ( "certs/ca.crt", root );

  grpc::SslServerCredentialsOptions::PemKeyCertPair keycert =
	{
		key,
		cert
	};
  grpc::SslServerCredentialsOptions sslOps;
  sslOps.pem_root_certs = root;
	sslOps.pem_key_cert_pairs.push_back ( keycert );
  builder.AddListeningPort(FLAGS_port, grpc::SslServerCredentials(sslOps));
  
  //auto credentials =  ::grpc::experimental::LocalServerCredentials(grpc_local_connect_type::LOCAL_TCP);
  //builder.AddListeningPort(FLAGS_port, credentials);

  ::grpc_compression_level compression_level = static_cast<grpc_compression_level>(FLAGS_compression_level);

  builder.SetMaxSendMessageSize(FLAGS_message_size)
  .SetMaxReceiveMessageSize(FLAGS_message_size)
  .SetDefaultCompressionLevel(compression_level);
  
  builder.RegisterService(&service  );
  std::unique_ptr<::grpc::Server> grpc_server(builder.BuildAndStart());

  // Run the server on a background thread.
  std::thread grpc_server_thread(
      [](::grpc::Server* grpc_server_ptr) {
        std::cout << "Server: listening on " << FLAGS_port << std::endl;
        grpc_server_ptr->Wait();
      },
      grpc_server.get());

  auto t_server = std::unique_ptr<Timer>(new Timer);

  while (!service.protocol_finished()) {
    // Wait for the server to be done, and then shut the server down.
  }

  // Shut down server.
  grpc_server->Shutdown();
  grpc_server_thread.join();
  t_server->cout_elapsed("Server grpc");
  t_total->cout_elapsed("Server total");
  return 0;
}

int main(int argc, char** argv) {
  google::InitGoogleLogging(argv[0]);
  gflags::ParseCommandLineFlags(&argc, &argv, true);

  return RunServer();
}
