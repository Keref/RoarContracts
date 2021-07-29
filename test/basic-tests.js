//var Messages = artifacts.require("Messages")
//var Profile = artifacts.require("Profile")
//var ProfileFactory = artifacts.require("ProfileFactory")
//var InteractionTips = artifacts.require("InteractionTips")
var ProfileLists = artifacts.require("ProfileLists")




contract("ProfileLists", async accounts => {
	var instance;
	var profileAddress;
	
	it("should have a first dummy list", async () => {
		instance = await ProfileLists.deployed();
		const earlyList = await instance.profileLists.call(0, {from: accounts[0] });
		assert.equal(earlyList, 'First List' );
	})
	
	it("should add a list", async () => {
		const res = await instance.createList("toto", {from: accounts[0] });
		assert.equal(res.logs[0].args.listId.toString(), "1" );
	})
	
	it("should add a follower", async () => {
		const res = await instance.addFollower(accounts[0], 1, {from: accounts[0] });
		const v = await instance.getList.call(1, {from: accounts[0] });
		assert.equal(v.profileAddresses[0], accounts[0] );
	})
	/*
	it("should fail to add twice the same follower", async () => {
		const res = await instance.addFollower(accounts[0], 1, {from: accounts[0] });
		const v = await instance.getList.call(1, {from: accounts[0] });
		assert.equal(v.profileAddresses[0], accounts[0] );
	})*/
	
	it("should create a default list and add 2 followers", async () => {
		let res = await instance.addFollower(accounts[0], 0, {from: accounts[0] }); //trying to add with id = 0
		const v = await instance.getList.call(2, {from: accounts[0] });
		assert.equal(v.profileAddresses[1], accounts[1] );
	})
	
	it("should remove a follower", async () => {
		let res = await instance.removeFollower(accounts[0], 0, {from: accounts[0] });
		const v = await instance.getList.call(2, {from: accounts[0] });
		assert.equal(v.profileAddresses[0], accounts[1] );
	})
	
	
	
});



/*
contract("ProfileFactory", async accounts => {
	var instance;
	var profileAddress;
	
	it("should have not have 'test' profile", async () => {
		instance = await ProfileFactory.deployed();
		const addressTest = await instance.getProfile.call('test', {from: accounts[0] });
		assert.equal(addressTest, 0 );
	})
	
	
	it("should create a test profile", async () => {
		const addressTest = await instance.deployNewProfile('test', {from: accounts[0] });
		assert.notEqual(addressTest, 0 );
	})
	
	it("should not create the 'test' profile since already taken", async () => {
		try {
			await instance.deployNewProfile('test', {from: accounts[0] });
		}
		catch (error) {
			assert(error.message.search('revert') >= 0);
			return;
		}
		assert.fail("Tx not reverted");
	})
	
	it("should update profile description", async () => {
		const res = await instance.deployNewProfile('test1', {from: accounts[0] });
		let eventName = res.logs[0].event;
        let eventRes = res.logs[0].args;

		assert.equal (eventName, 'ProfileCreated')
		
		profileAddress = eventRes[0];
		var myProfile = await Profile.at(profileAddress);
		
		const myDesc = 'hello work';
		await myProfile.setProfileDesc(myDesc, {from: accounts[0] });
		
		var description = await myProfile.description.call( {from: accounts[0] });
		
		assert.equal(description, myDesc );
	})
	
	
	it("should buy profile tokens", async () => {
		var myProfile = await Profile.at(profileAddress);
		
		var sale = await myProfile.buyStock({from: accounts[0], value: web3.utils.toWei('1') }); 
		var l = sale.logs[0];
		//console.log("Buy Event", l.args[0], l.args[1], l.args[2].toString() );
		assert.equal(l.event, 'Transfer');
	})
	
	it("should sell profile tokens", async () => {
		var myProfile = await Profile.at(profileAddress);
		
		var sale = await myProfile.sellStock( web3.utils.toWei('5'), { from: accounts[0] }); 
		var l = sale.logs[0];
		
		//console.log("Sell evt", l); //burn event emits Transfer from msg.sender to 0x0 of the token amount
		assert.equal(l.event, 'Transfer');
	})
	
	
})
*/
/*
contract("Messages", async accounts => {
	var profileAddress;
	
	it("should have 0 erc721", async () => {
		const instance = await Messages.deployed();
		const balance = await instance.totalSupply.call({from: accounts[0] });
		assert.equal(balance.valueOf(), 0 );
	})
	
	
	it("should publish a new message", async () => {
		const instanceM = await Messages.deployed();
		const instanceP = await ProfileFactory.deployed();
		const res = await instanceP.deployNewProfile('test1', {from: accounts[0] });
        let eventRes = res.logs[0].args;

		profileAddress = eventRes[0];
		
		var pub = await instanceM.publishMessage( profileAddress, 0, "Plip" );
		let eventName = pub.logs[0].event;
		assert.equal (eventName, 'MessagePublished');
	})
	
	it("should publish a new comment", async () => {
		const instanceM = await Messages.deployed();
		const instanceP = await ProfileFactory.deployed();
		
		var pub = await instanceM.publishMessage( profileAddress, 0, "Plip" );
		let eventName = pub.logs[0].event;
		assert.equal (eventName, 'MessagePublished');

		pub = await instanceM.publishMessage( profileAddress, 1, "Plip3" );
		eventName = pub.logs[0].event;
		assert.equal (eventName, 'CommentPublished');
		
		pub = await instanceM.getMessage.call(1, {from: accounts[0] });
	})
	
	it("should tip a comment", async () => {
		const instanceM = await Messages.deployed();
		const instanceP = await ProfileFactory.deployed();
		const instanceT = await InteractionTips.deployed();
		
		var pub = await instanceM.publishMessage( profileAddress, 0, "Plip" );
		let eventName = pub.logs[0].event;
		assert.equal (eventName, 'MessagePublished');

		pub = await instanceT.sendTip( 1, {from: accounts[0], value: 100000000000000000});
		eventName = pub.logs[0].event;
		assert.equal (eventName, 'TippedProfile');

	})

	
	
	
})
*/