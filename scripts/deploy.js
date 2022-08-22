const fs = require("fs");
const { saveFiles } = require("../test/utils");

const saveAbis = async () => {
    await saveFiles(
        "abis.json",
        JSON.stringify(
            {
                treasury: artifacts.readArtifactSync("Treasury").abi,
                token: artifacts.readArtifactSync("Token").abi
            },
            undefined,
            4
        )
    );
};

async function main() {
    saveAbis();
}

main()
    .then(() => {
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
