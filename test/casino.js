var Casino = artifacts.require("./Casino.sol");

contract("Casino", function (accounts) {
  var instance;

  beforeEach(async function () {
    instance = await Casino.deployed();
  });

  it("should return the max amount of bets", async () => {
    var count = await instance.maxAmountOfBets();

    assert.equal(count, 10);
  });

  describe("BETS", () => {
    it("should allow the user bet.", async () => {
      var response = await instance.bet(2, { value: 100 });

      var count = await instance.totalBet();

      assert.equal(count, 1);
    });

    it("should throw an error of user exist.", async () => {
      try {
        await instance.bet(10, { value: 100 });
      } catch (error) {
        assert(
          error.reason.indexOf("exists") >= 0,
          "error message must contain user exists."
        );
      }
    });

    it("should throw an error of bet must be be between 1 - 10", async () => {
      try {
        var response = await instance.bet(20, {
          value: 100,
          from: accounts[3],
        });
      } catch (error) {
        assert(
          error.reason.indexOf("number") >= 0,
          "error message must contain numbet to bet."
        );
      }
    });
  });
});
