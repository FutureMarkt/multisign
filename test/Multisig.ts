import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("Lock", function () {
  async function deployOneYearLockFixture() {
    const [owner, account1] = await hre.ethers.getSigners();

    const Multisig = await hre.ethers.getContractFactory("Lock");
    const multisig = await Multisig.deploy([owner, account1], 2);

    return { multisig, owner, account1 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { multisig, owner } = await loadFixture(deployOneYearLockFixture);

      expect(await multisig.owner()).to.equal(owner.address);
    });
  });
});
