var CloutMessages = artifacts.require("CloutMessages")
var CloutProfile = artifacts.require("CloutProfile")
var CloutProfileFactory = artifacts.require("CloutProfileFactory")
var InteractionTips = artifacts.require("InteractionTips")


module.exports = async function (deployer) {
	await deployer.deploy(CloutMessages);
	await deployer.deploy(CloutProfileFactory);
	
	/*
	let CMd = await CM.deployed();
	let CPFd = await CPF.deployed();*/
	
	let IT = await deployer.deploy( InteractionTips, CloutMessages.address, CloutProfileFactory.address);
};
