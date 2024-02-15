# Time Capsule Network

Welcome to the Time Capsule project, a unique endeavor aimed at leveraging the power of the Internet Computer (IC) to create a digital preservation platform. This project is designed to enable users to encapsulate their digital memories, ideas, and assets in time-locked capsules on the blockchain, ensuring their preservation and future accessibility. By participating in this project, you're not just engaging with cutting-edge technology; you're contributing to a collective memory bank that spans generations.

The Time Capsule project utilizes the decentralized nature of the Internet Computer to offer a secure, tamper-proof environment for users to create digital time capsules. These capsules can for now can contain text but eventually will allow images, videos, or any form of digital content that users wish to preserve for future retrieval. The content will be encrypted and set with an unlock date, ensuring that it remains inaccessible until the specified time.
## Background and Motivation

The genesis of the Time Capsule Network traces back to the skills and insights I gained from participating in Motoko Bootcamp training and delving into various lectures on Motoko development. I firmly believe that the most impactful ideas—the ones that truly drive innovation—are those that transcend the individual, stretching beyond our current capacities and comfort zones. This philosophy has shaped my approach to exploring the possibilities within the IC ecosystem, despite the challenges of being relatively new to Motoko and IC development.

The conception of the Time Capsule Network was fueled by a desire to create something that was not only simple and enjoyable but also significant enough to stand as a testament to human creativity and the relentless pursuit of growth. The project, in its current form, is still in the early stages of development, lacking in certain aspects that would render it fully complete. However, it embodies a "skeletal structure," equipped with a "working brain" and a "beating heart." This foundational framework serves as a starting point, a canvas upon which we can collectively paint a more detailed and vibrant future.

This project is more than just a technical endeavor; it's a journey of learning, experimentation, and community collaboration. It represents an opportunity to bring a unique idea to life—one that not only challenges my capabilities but also contributes to the broader narrative of innovation on the Internet Computer Protocol. With each contribution and enhancement, it moves closer to realizing its full potential as a living, breathing entity within the digital ecosystem.

## Current Limitations and Future Directions

The Time Capsule Network, in its current iteration, showcases the foundational structure and functionality envisioned for a platform that allows users to create digital time capsules. However, there are several limitations and areas awaiting further development:

### DApp Limits for Security Assurance

To ensure security and manageability, defining operational limits is crucial. Currently, the dApp lacks predefined limits such as:

- `MAX_USERS` = 1,000; Maximum number of users
- `MAX_CAPSULES_PER_USER` = 500; Maximum number of capsules a user can create
- `MAX_DEVICES_PER_USER` = 6; Maximum number of devices per user
- `MAX_CAPSULE_CHARS` = 100; Maximum character count for a capsule
- `MAX_DEVICE_ALIAS_LENGTH` = 200; Maximum length for device aliases
- `MAX_PUBLIC_KEY_LENGTH` = 500; Maximum length for public keys
- `MAX_CIPHERTEXT_LENGTH` = 40,000; Maximum length for ciphertexts

### Encryption and Security

The current version of the dApp does not employ encryption techniques for the capsules. Implementing robust encryption is essential for ensuring the privacy and security of the content stored within the time capsules.

### Frontend Development

The dApp is yet to have a fully functional frontend canister. The interface for interacting with the Time Capsule Network is under development, aiming to provide a seamless and user-friendly experience.

### Multimedia Content

As of now, users are restricted to text-only content for their capsules. Future versions intend to support various forms of multimedia, allowing users to preserve a richer array of memories and information.

### Code Optimization and Structure Improvement

While the backend logic is in place, there's always room for optimization and structural improvements. Each function can be re-evaluated for efficiency and scalability, ensuring the dApp can evolve and handle increased user activity over time.

### Collaboration and Team Development

The conception, refinement, and development of the Time Capsule Network has been a solo journey. In retrospect, collaboration with a team could have accelerated development and introduced diverse perspectives, significantly enhancing the project's scope and capabilities.

---

These limitations not only highlight the current state of the Time Capsule Network but also outline the roadmap for its evolution. The journey ahead is filled with opportunities for growth, innovation, and community collaboration.


To learn more before you start working with Time Capsule Network, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)

If you want to start working on the project right away,try the following commands:

```bash
cd timecapsule/
dfx help
dfx canister --help
```

## Running the project locally

If you want to test the project locally, you can use the following commands:

```bash
#Enter the project
cd timecapsule/

# Starts the replica
dfx start --clean

#Deploy Internet Identity Canister
dfx  deps deploy 

# Deploys canisters to the replica and generates  candid interface
dfx deploy timecapsule
```

Once the job completes, application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.

If you have made changes to the backend canister, you can generate a new candid interface with

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

