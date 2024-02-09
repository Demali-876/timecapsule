import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Types "types";

actor DAO {
        type TokenFaucetResult = { #ok; #err : Text };
        type TokenFaucetActor = actor {
        balanceOf : shared query (Principal) -> async Nat;
        balanceOfArray : shared query ([Principal]) -> async [Nat];
        burn : shared (Principal, Nat) -> async TokenFaucetResult;
        mint : shared (Principal, Nat) -> async TokenFaucetResult;
        tokenName : shared query () -> async Text;
        tokenSymbol : shared query () -> async Text;
        totalSupply : shared query () -> async Nat;
        transfer : shared (Principal, Principal, Nat) -> async TokenFaucetResult;
        };

        type Result<A, B> = Result.Result<A, B>;
        type Member = Types.Member;
        type ProposalContent = Types.ProposalContent;
        type ProposalId = Types.ProposalId;
        type Proposal = Types.Proposal;
        type Vote = Types.Vote;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;

        stable let canisterIdWebpage : Principal = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"); // TODO: Change this to the ID of your webpage canister
        stable var manifesto = "To discover, celebrate, and elevate the best Motoko programmers in the world";
        stable let name = "Motoko Arena";
        stable var goals = [];
        let tokenFaucetCanisterId = "jaamb-mqaaa-aaaaj-qa3ka-cai";
        let tokenFaucet : TokenFaucetActor = actor(tokenFaucetCanisterId);
        let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

        // Returns the name of the DAO
        public query func getName() : async Text {
                return name;
        };

        // Returns the manifesto of the DAO
        public query func getManifesto() : async Text {
                return manifesto;
        };

        // Returns the goals of the DAO
        public query func getGoals() : async [Text] {
                return goals;
        };

        // Register a new member in the DAO with the given name and principal of the caller
        // Airdrop 10 MBC tokens to the new member
        // New members are always Student
        // Returns an error if the member already exists
        public shared ({ caller }) func registerMember(name : Text) : async Result<(), Text> {
                 switch (members.get(caller)) {
            case (null) {
                // Member does not exist, proceed with registration
                let newMember = {
                    name = name;
                    role = #Student;
                };
                // Add the new member to the registry
                members.put(caller, newMember);
                // Airdrop tokens to the new member
                //handle result
                switch(await tokenFaucet.mint(caller, 10)) {
                        case(#ok) {return #ok  };
                        case(#err(errMsg)) {return #err("Error minting from from faucet" ) };
                };
            };
            case (_) {
                // Member already exists
                return #err("Member already exists");
                        };
                };
        };

        // Get the member with the given principal
        // Returns an error if the member does not exist
        public query func getMember(p : Principal) : async Result<Member, Text> {
                switch (members.get(p)) {
                        case (null) {
                                return #err("Member does not exist");
                        };
                        case (?member) {
                                return #ok(member);
                        };
                };
        };

        // Graduate the student with the given principal
        // Returns an error if the student does not exist or is not a student
        // Returns an error if the caller is not a mentor
        public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
        // Check if the caller is a Mentor
        switch (members.get(caller)) {
                case (null) {
                return #err("Caller is not a registered member");
                };
                case (?member) {
                switch (member.role) {
                        case (#Mentor) {
                        // Caller is a Mentor, now validate the student
                        switch (members.get(student)) {
                                case (null) {
                                return #err("Student does not exist");
                                };
                                case (?studentMember) { // studentMember is the data associated with the student Principal
                                switch (studentMember.role) {
                                        case (#Student) {
                                        // Valid student, proceed with graduation
                                        members.put(student, {name = studentMember.name; role = #Graduate});
                                        return #ok();
                                        };
                                        case (_) { return #err("Member is not a student or already graduated");};
                                                };
                                        };
                                };
                        };
                        case (_) {return #err("Caller is not a mentor");};
                                };
                        };
                };
        };


        // Create a new proposal and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        var nextProposalId : Nat64 = 0;
        let proposals = HashMap.HashMap<ProposalId, Proposal>(0, Nat64.equal, Nat64.toNat32);
        public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
        switch (members.get(caller)) {
                case (null) {
                // The caller is not a registered member
                return #err("The caller is not a member - cannot create a proposal");
                };
                case (?member) {
                switch(member.role) {
                        case (#Mentor) { // Ensure this matches exactly how the Mentor role is defined in your Role type
                        // Fetch the caller's token balance using the token faucet canister
                        let balance : Nat = await tokenFaucet.balanceOf(caller);
                        if (balance < 1) {
                                return #err("The caller does not have enough tokens to create a proposal");
                        };

                        // Attempt to burn a token before creating the proposal
                        switch(await tokenFaucet.burn(caller, 1)) {
                                case (#ok) {
                                // Proceed with creating the proposal since the token burn was successful
                                };
                                case (#err(errMsg)) {
                                return #err("Failed to burn tokens ");
                                };
                        };

                        // Capture the current proposal ID
                        let proposalId = nextProposalId;
                        // Create the proposal
                        let proposal : Proposal = {
                                content = content;
                                creator = caller;
                                created = Time.now();
                                executed = null;
                                votes = [];
                                voteScore = 0;
                                status = #Open;
                        };
                        proposals.put(proposalId, proposal);
                        nextProposalId += 1; // Increment the proposal ID for the next proposal
                        return #ok(proposalId);
                        };
                        case (_) {
                        return #err("Only mentors are authorized to create proposals");
                                        };
                                };
                        };
                };
        };


        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
                return #err("Not implemented");
        };

        // Returns all the proposals
        public query func getAllProposal() : async [Proposal] {
                return [];
        };

        // Vote for the given proposal
        // Returns an error if the proposal does not exist or the member is not allowed to vote
        public shared ({ caller }) func voteProposal(proposalId : ProposalId, yesOrNo : Bool) : async Result<(), Text> {
                return #err("Not implemented");
        };

        // Returns the Principal ID of the Webpage canister associated with this DAO
        public query func getIdWebpage() : async Principal {
                return Principal.fromText("aaaaa-aa");
        };

};