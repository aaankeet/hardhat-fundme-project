require("dotenv").config()
require("@nomiclabs/hardhat-etherscan")
require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")

const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        rinkeby: {
            url: RINKEBY_RPC_URL,
            account: [PRIVATE_KEY],
            chainId: 4,
            blockConfirmations: 6,
        },
        polygon: {
            url: POLYGON_RPC_URL,
            account: [PRIVATE_KEY],
            chainId: 80001,
            blockConfirmations: 4,
        },
    },
    solidity: {
        compilers: [{ version: "0.8.8" }, { version: "0.6.6" }],
    },

    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        currency: "USD",
        noColors: true,
        coinmarketcap: COINMARKETCAP_API_KEY,
        token: "Matic",
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
            1: 0,
        },
    },
}
