// @see https://learn.microsoft.com/en-us/power-platform/developer/playwright-samples/global-setup-teardown

const NODE_API_URL = "http://127.0.0.1:8001/";
const READY_TIMEOUT_MS = 120_000;

export default async function globalSetup() {
  const deadline = Date.now() + READY_TIMEOUT_MS;
  let isReady = false;

  while (!isReady && Date.now() < deadline) {
    try {
      const response = await fetch(NODE_API_URL);
      isReady = response.ok;
    } catch {
      isReady = false;
    }

    if (!isReady) {
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }

  if (!isReady) {
    throw new Error(
      `Timed out after ${READY_TIMEOUT_MS}ms waiting for the Node API at ${NODE_API_URL}`,
    );
  }
}
