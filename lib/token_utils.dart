import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import "package:http/http.dart" as http;

class TokenUtils {
  late Web3Client web3client;
  late http.Client httpClient;
  final contractAddress = dotenv.env["TOKEN_ADDRESS"];

  void initial() {
    httpClient = http.Client();
    web3client = Web3Client(dotenv.env["NODE_URL"]!, httpClient);
  }

  Future<double> isApproved() async {
    print("check allowance");
    final contract = await getDeployedContract();
    final ethFunction = contract.function("allowance");
    final owner = EthereumAddress.fromHex(dotenv.env["WALLET_ADDRESS4"]!);
    final spender = EthereumAddress.fromHex(dotenv.env["STAKING_ADDRESS"]!);
    final result = await web3client.call(
      contract: contract,
      function: ethFunction,
      params: [
        owner,
        spender,
      ],
    );
    return result[0].toDouble() / pow(10, 18);
  }

  Future<double> getMyBalance() async {
    final contract = await getDeployedContract();
    final ethFunction = contract.function("balanceOf");
    final address = EthereumAddress.fromHex(dotenv.env["WALLET_ADDRESS4"]!);
    final result = await web3client.call(
      contract: contract,
      function: ethFunction,
      params: [address],
    );
    return result[0].toDouble() / pow(10, 18);
  }

  Future<String> approval(int amount) async {
    print("melakukan approval");
    BigInt bInt = BigInt.from(amount);
    EthPrivateKey privateKey =
        EthPrivateKey.fromHex(dotenv.env["PRIVATE_KEY4"]!);
    final contract = await getDeployedContract();
    final ethFunction = contract.function("approve");
    final chainId = await web3client.getChainId();
    final spenderContract =
        EthereumAddress.fromHex(dotenv.env["STAKING_ADDRESS"]!);
    final result = web3client.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [
          spenderContract,
          bInt,
        ],
      ),
      chainId: chainId.toInt(),
    );
    return result;
  }

  Future<DeployedContract> getDeployedContract() async {
    final abi = await rootBundle.loadString("assets/token.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "IztarToken"),
        EthereumAddress.fromHex(contractAddress!));
    return contract;
  }
}
