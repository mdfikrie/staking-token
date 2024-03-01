import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class StakeUtils {
  late Web3Client web3client;
  late http.Client httpClient;
  final contractAddress = dotenv.env["STAKING_ADDRESS"];

  void initial() {
    httpClient = http.Client();
    web3client = Web3Client(dotenv.env["NODE_URL"]!, httpClient);
  }

  Future<double> totalStaked() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("getTotalStaked");
    final result = await web3client
        .call(contract: contract, function: ethFunction, params: []);
    return result[0].toDouble() / pow(10, 18);
  }

  Future<double> myStaking() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("balanceOf");
    final address = EthereumAddress.fromHex(dotenv.env["WALLET_ADDRESS4"]!);
    final result = await web3client.call(
      contract: contract,
      function: ethFunction,
      params: [address],
    );

    return result[0].toDouble() / pow(10, 18);
  }

  Future<double> minStake() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("getMinStake");
    final result = await web3client
        .call(contract: contract, function: ethFunction, params: []);
    return result[0].toDouble() / pow(10, 18);
  }

  Future<double> apr() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("getAPR");

    final result = await web3client
        .call(contract: contract, function: ethFunction, params: []);
    return result[0].toDouble();
  }

  Future<double> maxStake() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("getMaxStake");
    final result = await web3client
        .call(contract: contract, function: ethFunction, params: []);
    print(result[0]);
    return result[0].toDouble() / 1000000000000000000;
  }

  Future<String> stake(int amount) async {
    print("melakukan stake");
    var bigInt = BigInt.from(amount);
    EthPrivateKey privateKey =
        EthPrivateKey.fromHex(dotenv.env["PRIVATE_KEY4"]!);
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("stake");
    final chainId = await web3client.getChainId();
    final tokenContract = EthereumAddress.fromHex(dotenv.env["TOKEN_ADDRESS"]!);
    final result = await web3client.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [
          bigInt,
          tokenContract,
        ],
      ),
      chainId: chainId.toInt(),
      fetchChainIdFromNetworkId: false,
    );
    return result;
  }

  Future<String> unstake(int amount) async {
    print("melakukan unstake");
    BigInt bInt = BigInt.from(amount);
    final privateKey = EthPrivateKey.fromHex(dotenv.env["PRIVATE_KEY4"]!);
    final contract = await getDeployedContract();
    final ethFunction = contract.function("unstake");
    final chainId = await web3client.getChainId();
    final result = await web3client.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [
          bInt,
        ],
      ),
      chainId: chainId.toInt(),
    );

    return result;
  }

  Future<String> claimReward() async {
    final privateKey = EthPrivateKey.fromHex(dotenv.env["PRIVATE_KEY4"]!);
    final contract = await getDeployedContract();
    final ethFunction = contract.function("claimReward");
    final chainId = await web3client.getChainId();
    final result = await web3client.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [],
      ),
      chainId: chainId.toInt(),
    );
    return result;
  }

  Future<String> restake() async {
    print("restake");
    final privateKey = EthPrivateKey.fromHex(dotenv.env["PRIVATE_KEY4"]!);
    final contract = await getDeployedContract();
    final ethFunction = contract.function("restake");
    final chainId = await web3client.getChainId();
    final result = await web3client.sendTransaction(
      privateKey,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [],
      ),
      chainId: chainId.toInt(),
    );
    return result;
  }

  Future<double> rewardAvailable() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("rewardAvailable");
    final account = EthereumAddress.fromHex(dotenv.env["WALLET_ADDRESS4"]!);
    final result = await web3client
        .call(contract: contract, function: ethFunction, params: [account]);
    return result[0].toDouble() / pow(10, 18);
  }

  Future<double> rewardClaimed() async {
    DeployedContract contract = await getDeployedContract();
    final ethFunction = contract.function("rewardClaimed");
    final account = EthereumAddress.fromHex(dotenv.env["WALLET_ADDRESS4"]!);
    final result = await web3client
        .call(contract: contract, function: ethFunction, params: [account]);
    return result[0].toDouble() / pow(10, 18);
  }

  Future<DeployedContract> getDeployedContract() async {
    String abi = await rootBundle.loadString("assets/staking.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "TokenStaking"),
        EthereumAddress.fromHex(contractAddress!));
    return contract;
  }
}
