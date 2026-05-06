#!/usr/bin/env bash

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=$PWD/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
echo "Starting Hyperledger Fabric cleanup..."

# Navigate to test-network
cd ~/fabric-sample/test-network || exit 1

echo "Stopping Fabric network..."
./network.sh down || true

echo "Removing all Docker containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

echo "Removing Fabric Docker images (chaincode + env)..."
docker images | grep dev-peer | awk '{print $3}' | xargs -r docker rmi -f
docker images | grep hyperledger | awk '{print $3}' | xargs -r docker rmi -f

echo "Removing Docker volumes..."
docker volume prune -f || true

echo "Pruning system (containers, networks, cache)..."
docker system prune -a --volumes -f

echo "Cleaning generated Fabric artifacts..."

rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf channel-artifacts/*
rm -rf system-genesis-block/*
rm -rf log.txt
rm -rf *.tar.gz

echo "Cleanup complete. Environment is fresh."

