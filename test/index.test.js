import path from "path";
import * as types from "@onflow/types";
import {
  init,
  sendTransaction,
  deployContractByName,
  getTransactionCode,
} from "flow-js-testing/dist";
import { getScriptCode } from "flow-js-testing/dist/utils/file";
import { executeScript } from "flow-js-testing/dist/utils/interaction";
import { getContractAddress } from "flow-js-testing/dist/utils/contract";
import { getAccountAddress } from "flow-js-testing/dist/utils/create-account";

const basePath = path.resolve(__dirname, "../cadence");

beforeAll(() => {
  init(basePath);
});

describe("Replicate Playground Accounts", () => {
  test("Create Accounts", async () => {
    // Playground project support 4 accounts, but nothing stops you from creating more by following the example laid out below
    const Alice = await getAccountAddress("Alice");
    const Bob = await getAccountAddress("Bob");
    const Charlie = await getAccountAddress("Charlie");
    const Dave = await getAccountAddress("Dave");

    console.log(
      "Four Playground accounts were created with following addresses"
    );
    console.log("Alice:", Alice);
    console.log("Bob:", Bob);
    console.log("Charlie:", Charlie);
    console.log("Dave:", Dave);
  });
});

describe("Deployment", () => {
  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("Alice");

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy  contract", async () => {
    const name = "";
    const to = await getAccountAddress("Bob");

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");

    const addressMap = {
      NonFungibleToken,
    };

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
        addressMap,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy HelloWorld contract", async () => {
    const name = "HelloWorld";
    const to = await getAccountAddress("Charlie");

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy HelloWorld contract", async () => {
    const name = "HelloWorld";
    const to = await getAccountAddress("Dave");

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });

  test("Deploy HelloWorld contract", async () => {
    const name = "HelloWorld";
    const to = await getAccountAddress("");

    let result;
    try {
      result = await deployContractByName({
        name,
        to,
      });
    } catch (e) {
      console.log(e);
    }

    expect(result.errorMessage).toBe("");
  });
});

describe("Transactions", () => {
  test("test transaction template SetupAccount", async () => {
    const name = "SetupAccount";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template CollectionExist", async () => {
    const name = "CollectionExist";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template Mint", async () => {
    const name = "Mint";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
      ["Hello", "Hello", types.String],
    ];

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template Transfer", async () => {
    const name = "Transfer";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
    ];

    // Generate addressMap from import statements
    const NonFungibleToken = await getContractAddress("NonFungibleToken");
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      NonFungibleToken,
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template UpdateTokenURI", async () => {
    const name = "UpdateTokenURI";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [
      [64, types.UInt64],
      ["Hello", types.String],
    ];

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });

  test("test transaction template Burn", async () => {
    const name = "Burn";

    // Import participating accounts
    const Alice = await getAccountAddress("Alice");

    // Set transaction signers
    const signers = [Alice];

    // Define arguments
    const args = [[64, types.UInt64]];

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getTransactionCode({
      name,
      addressMap,
    });

    let txResult;
    try {
      txResult = await sendTransaction({
        code,
        args,
        signers,
      });
    } catch (e) {
      console.log(e);
    }

    expect(txResult.errorMessage).toBe("");
  });
});

describe("Scripts", () => {
  test("test script template GetNFT", async () => {
    const name = "GetNFT";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
    ];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetOwnerOf", async () => {
    const name = "GetOwnerOf";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [[64, types.UInt64]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTokenURI", async () => {
    const name = "GetTokenURI";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [[64, types.UInt64]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTokenContentHash", async () => {
    const name = "GetTokenContentHash";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [[64, types.UInt64]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTokenCreator", async () => {
    const name = "GetTokenCreator";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [[64, types.UInt64]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetStorageUsed", async () => {
    const name = "GetStorageUsed";

    let code = await getScriptCode({
      name,
    });

    // Define arguments
    const args = [["0x0ae53cb6e3f42a79", types.Address]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTokenIdByIndex", async () => {
    const name = "GetTokenIdByIndex";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [[64, types.UInt64]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetCollectionLen", async () => {
    const name = "GetCollectionLen";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [["0x0ae53cb6e3f42a79", types.Address]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTokenIdByContentHash", async () => {
    const name = "GetTokenIdByContentHash";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [["Hello", types.String]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetTotalSupply", async () => {
    const name = "GetTotalSupply";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    const result = await executeScript({
      code,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template IsOwned", async () => {
    const name = "IsOwned";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [
      ["0x0ae53cb6e3f42a79", types.Address],
      [64, types.UInt64],
    ];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });

  test("test script template GetAllTokenIds", async () => {
    const name = "GetAllTokenIds";

    // Generate addressMap from import statements
    const PxbeeMedia = await getContractAddress("PxbeeMedia");

    const addressMap = {
      PxbeeMedia,
    };

    let code = await getScriptCode({
      name,
      addressMap,
    });

    // Define arguments
    const args = [["0x0ae53cb6e3f42a79", types.Address]];

    const result = await executeScript({
      code,
      args,
    });

    // Add your expectations here
    expect().toBe();
  });
});
