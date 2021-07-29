var Messages = artifacts.require("Messages")
var Profile = artifacts.require("Profile")
var ProfileFactory = artifacts.require("ProfileFactory")
var InteractionTips = artifacts.require("InteractionTips")
var ProfileLists = artifacts.require("ProfileLists")


module.exports = async function (deployer) {
	await deployer.deploy(Messages);
	await deployer.deploy(ProfileFactory);
	
	/*
	let CMd = await CM.deployed();
	let CPFd = await CPF.deployed();*/
	
	let IT = await deployer.deploy( InteractionTips, Messages.address, ProfileFactory.address);
	
	await deployer.deploy(ProfileLists);
};
