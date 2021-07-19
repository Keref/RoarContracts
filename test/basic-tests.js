var CloutMessages = artifacts.require("CloutMessages")
var CloutProfile = artifacts.require("CloutProfile")
var CloutProfileFactory = artifacts.require("CloutProfileFactory")
var InteractionTips = artifacts.require("InteractionTips")


contract("CloutProfileFactory", async accounts => {
	var instance;
	var profileAddress;
	
	it("should have not have 'test' profile", async () => {
		instance = await CloutProfileFactory.deployed();
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
		var myProfile = await CloutProfile.at(profileAddress);
		
		const myDesc = 'hello cloutwork';
		await myProfile.setProfileDesc(myDesc, {from: accounts[0] });
		
		var description = await myProfile.description.call( {from: accounts[0] });
		
		assert.equal(description, myDesc );
	})
	
	
	it("should buy profile tokens", async () => {
		var myProfile = await CloutProfile.at(profileAddress);
		
		var sale = await myProfile.buyStock({from: accounts[0], value: web3.utils.toWei('1') }); 
		var l = sale.logs[0];
		//console.log("Buy Event", l.args[0], l.args[1], l.args[2].toString() );
		assert.equal(l.event, 'Transfer');
	})
	
	it("should sell profile tokens", async () => {
		var myProfile = await CloutProfile.at(profileAddress);
		
		var sale = await myProfile.sellStock( web3.utils.toWei('5'), { from: accounts[0] }); 
		var l = sale.logs[0];
		
		//console.log("Sell evt", l); //burn event emits Transfer from msg.sender to 0x0 of the token amount
		assert.equal(l.event, 'Transfer');
	})
	
	
})

/*
contract("CloutMessages", async accounts => {
	var profileAddress;
	
	it("should have 0 erc721", async () => {
		const instance = await CloutMessages.deployed();
		const balance = await instance.totalSupply.call({from: accounts[0] });
		assert.equal(balance.valueOf(), 0 );
	})
	
	
	it("should publish a new message", async () => {
		const instanceM = await CloutMessages.deployed();
		const instanceP = await CloutProfileFactory.deployed();
		const res = await instanceP.deployNewProfile('test1', {from: accounts[0] });
        let eventRes = res.logs[0].args;

		profileAddress = eventRes[0];
		
		var pub = await instanceM.publishMessage( profileAddress, 0, "Plip" );
		let eventName = pub.logs[0].event;
		assert.equal (eventName, 'MessagePublished');
	})
	
	it("should publish a new comment", async () => {
		const instanceM = await CloutMessages.deployed();
		const instanceP = await CloutProfileFactory.deployed();
		
		var pub = await instanceM.publishMessage( profileAddress, 0, "Plip" );
		let eventName = pub.logs[0].event;
		assert.equal (eventName, 'MessagePublished');

		pub = await instanceM.publishMessage( profileAddress, 1, "Plip3" );
		eventName = pub.logs[0].event;
		assert.equal (eventName, 'CommentPublished');
		
		pub = await instanceM.getMessage.call(1, {from: accounts[0] });
	})
	
	it("should tip a comment", async () => {
		const instanceM = await CloutMessages.deployed();
		const instanceP = await CloutProfileFactory.deployed();
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