const crypto = require("crypto");
const { Octokit } = require("@octokit/rest");
const { createPullRequest, DELETE_FILE } = require("octokit-plugin-create-pull-request");

const GithubClient = Octokit.plugin(createPullRequest);

const client = new GithubClient({
  auth: process.env.GITHUB_AUTH_TOKEN,
});

async function createExamplesPR(
  type,
  json,
  author = { name: "Test User", email: "test@user.org" },
) {
  // Using dynamic import to avoid jest runtime error
  // eg. “A dynamic import callback was invoked without --experimental-vm-modules”
  const prettier = require("prettier");
  if (!type) throw new Error("type is missing");
  if (type !== "food" && type !== "textile")
    throw new Error(`Type should be food or textile, you provided '${type}'.`);
  if (!json) throw new Error("json is missing");
  const [owner, repo] = process.env.GITHUB_REPOSITORY.split("/");
  if (!owner) throw new Error("owner is missing");
  if (!repo) throw new Error("repo is missing");
  const date = new Date().toISOString().substring(0, 10);
  const head = `contrib-${date}-${crypto.randomBytes(4).toString("hex")}`;
  const jsonString = JSON.stringify(json, null, 2);
  const filepath = `${__dirname}/../public/data/${type}/examples.json`;
  const formattedJson = await prettier.format(jsonString, { filepath });
  return await client.createPullRequest({
    owner,
    repo,
    head,
    title: `[${date}] Update ${type} product examples.`,
    body: `A few updates on ${type} product examples.`,
    base: process.env.GITHUB_BRANCH,
    update: false,
    forceFork: false,
    labels: [],
    changes: [
      {
        author,
        files: { [`public/data/${type}/examples.json`]: formattedJson },
        commit: `Update ${type} product examples.`,
        commiter: { name: "Ecobalyse Robot", email: "ecobalyse@beta.gouv.fr" },
      },
    ],
  });
}

module.exports = { createExamplesPR };
