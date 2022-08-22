const { expect } = require("chai");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const { delay, fromBigNum, toBigNum, saveFiles, sign } = require("./utils.js");

// owner
var owner, userWallet, provider, chainId, chainName;
var treasury, token;

// deploy mode
const isDeploy = true;

var addresses = {};
try {
    const addressesJson = require("../build/addresses.json");
    addresses = addressesJson;
} catch (err) {
}

describe("Create UserWallet", function () {
    it("Create account", async function () {
        [owner, userWallet] = await ethers.getSigners();
        provider = ethers.provider;

        chainId = (await provider.getNetwork()).chainId;
        let balance = await provider.getBalance(owner.address);
        console.log(owner.address, userWallet.address, chainId, fromBigNum(balance));
    });
});

describe("deploy contract", function () {
    it("deploy treasury", async function () {
        const Factory = await ethers.getContractFactory("Treasury");
        if (isDeploy) {
            treasury = await Factory.deploy();
            await treasury.deployed();
        } else {
            treasury = Factory.attach(addresses[chainId].treasury)
        }
    });
    it("deploy token", async function () {
        const Factory = await ethers.getContractFactory("Token");
        if (isDeploy) {
            token = await Factory.deploy(toBigNum(10 ** 8));
            await token.deployed();
            // fill token to bridge
            tx = await token.transfer(treasury.address, toBigNum(10 ** 7));
            await tx.wait();
            //set bridge token
            var tx = await treasury.setTokenAddress(token.address);
            await tx.wait();
        } else {
            token = Factory.attach(addresses[chainId].token)
        }
    });
});

if (!isDeploy) {
    describe("test contract", function () {
        it("approve token", async function () {
            var tx = await token.approve(treasury.address, toBigNum(1000000, 8));
            await tx.wait();
        });
        it("deposit token", async function () {
            var tx = await treasury.deposit(toBigNum(1000, 8), "4002");
            await tx.wait();
        });
        // it("withdraw", async function () {
        //     var tos = new Array(10).fill(userWallet.address);
        //     var amounts = new Array(10).fill(toBigNum(0.01));
        //     var tx = await treasury.multiSend(tos, amounts);
        //     await tx.wait();
        // });
    });
}

describe("Save contracts", function () {
    it("save abis", async function () {
        const abis = {
            treasury: artifacts.readArtifactSync("Treasury").abi,
            token: artifacts.readArtifactSync("Token").abi
        };
        await saveFiles("abis.json", JSON.stringify(abis, undefined, 4));
    });
    it("save addresses", async function () {

        addresses = {
            ...addresses,
            [chainId]: {
                treasury: treasury.address,
                token: token.address
            }
        };
        await saveFiles(
            `addresses.json`,
            JSON.stringify(addresses, undefined, 4)
        );
    });
});