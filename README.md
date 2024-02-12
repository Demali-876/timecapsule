# Time Capsule Network

Welcome to the Time Capsule project, a unique endeavor aimed at leveraging the power of the Internet Computer (IC) to create a digital preservation platform. This project is designed to enable users to encapsulate their digital memories, ideas, and assets in time-locked capsules on the blockchain, ensuring their preservation and future accessibility. By participating in this project, you're not just engaging with cutting-edge technology; you're contributing to a collective memory bank that spans generations.

The Time Capsule project utilizes the decentralized nature of the Internet Computer to offer a secure, tamper-proof environment for users to create digital time capsules. These capsules can for now can contain text but eventually will allow images, videos, or any form of digital content that users wish to preserve for future retrieval. The content will be encrypted and set with an unlock date, ensuring that it remains inaccessible until the specified time.

To learn more before you start working with Time Capsule Network, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)

If you want to start working on your project right away, you might want to try the following commands:

```bash
cd timecapsule/
dfx help
dfx canister --help
```

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.

If you have made changes to your backend canister, you can generate a new candid interface with

```bash
npm run generate
```

at any time. This is recommended before starting the frontend development server, and will be run automatically any time you run `dfx deploy`.

If you are making frontend changes, you can start a development server with

```bash
npm start
```

Which will start a server at `http://localhost:8080`, proxying API requests to the replica at port 4943.

I am excited to have you on this journey with us I build a digital legacy on the Internet Computer. Your contributions and engagement will help shape the future of digital preservation, making the Time Capsule project a cornerstone of the IC ecosystem. Let's create a lasting legacy together!
## Contributing

Your contributions could transform the Time Capsule project into a vibrant and innovative platform. Whether you're a developer, designer, content creator, or enthusiast, there are numerous ways to contribute:

- **Code Contributions:** Submit pull requests with bug fixes, feature additions, or performance enhancements.
- **Documentation:** Help improve or expand the project's documentation for better accessibility and understanding.
- **Feedback and Ideas:** Participate in discussions, provide feedback on existing features, and suggest new ideas or improvements.

```

