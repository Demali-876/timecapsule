import { createActor } from "../../declarations/timecapsule_backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

// Initialize the actor with a placeholder; this will be properly initialized after authentication
let actor;

// Function to update the UI for an authenticated user, showing their principal
function updateUIForAuthenticatedUser(principal) {
    const loginButton = document.getElementById("login");
    loginButton.innerText = principal.substring(0, 5) + '***' + principal.substring(principal.length - 3);
    loginButton.setAttribute('data-full-principal', principal); // Store the full principal for potential future use
    loginButton.onclick = function(e) {
        e.preventDefault(); // Prevent default click action
    };
}

// Function to initialize the AuthClient and set up the actor
async function initAuthClient() {
    const authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
        // User is already authenticated, so set up the actor with their identity
        const identity = authClient.getIdentity();
        const userPrincipal = identity._principal.toString();
        const agent = new HttpAgent({ identity });
        actor = createActor(process.env.CANISTER_ID_TIMECAPSULE_BACKEND, { agent });
        updateUIForAuthenticatedUser(userPrincipal);
    } else {
        // Automatically prompt the user to log in
        authClient.login({
            identityProvider: process.env.DFX_NETWORK === "ic" ? "https://identity.ic0.app" : "http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943",
            onSuccess: async () => {
                // After successful login, set up the actor with the new identity
                const identity = authClient.getIdentity();
                const userPrincipal = identity._principal.toString();
                const agent = new HttpAgent({ identity });
                actor = createActor(process.env.CANISTER_ID_TIMECAPSULE_BACKEND, { agent });
                updateUIForAuthenticatedUser(userPrincipal);
            },
        });
    }
}
window.onload = initAuthClient;

