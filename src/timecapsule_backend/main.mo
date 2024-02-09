import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Types "types";
import Array "mo:base/Array";

actor timeCapsuleDAO {

  type Member = Types.Member;
  type Result<Ok, Err> = Types.Result<Ok, Err>;
  type HashMap<K, V> = Types.HashMap<K, V>;
  type Proposal = Types.Proposal;
  type ProposalContent = Types.ProposalContent;
  type ProposalId = Types.ProposalId;
  type Vote = Types.Vote;
  type TimeCapsuleId = Types.TimeCapsuleId;
  type UnlockDate = Types.UnlockDate;
  type TimeCapsuleContentType = Types.TimeCapsuleContentType;
  type StructuredContent = Types.StructuredContent;
  type TimeCapsule = Types.TimeCapsule;
  type ProposalStatus = Types.ProposalStatus;

  let name = "Time Capsule Network";
  var manifesto = " To preserve and share humanity's collective memory across generations by leveraging blockchain technology";
  let goals = Buffer.Buffer<Text>(0);
  let requests = Buffer.Buffer<Text>(0);

  public shared query func getName() : async Text {
        return name;
    };
    public shared query func getManifesto() : async Text {
        return manifesto;
    };
    public func setManifesto(newManifesto : Text) : async () {
        manifesto := newManifesto;
        return;
    };
    public func addGoal(newGoal : Text) : async () {
        goals.add(newGoal);
        return;
    };
    public shared query func getGoals() : async [Text] {
        Buffer.toArray(goals);
    };
    let tcnledger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    public query func tokenName() : async Text {
        return "Time Capsule Network";
    };

    public query func tokenSymbol() : async Text {
        return "TCN";
    };

    private func mint(owner : Principal, amount : Nat) : async Result<(), Text> {
        let balance = Option.get(tcnledger.get(owner), 0);
        tcnledger.put(owner, balance + amount);
        return #ok();
    };

    private func burn(owner : Principal, amount : Nat) : async Result<(), Text> {
        let balance = Option.get(tcnledger.get(owner), 0);
        if (balance < amount) {
            return #err("Insufficient balance to burn");
        };
        tcnledger.put(owner, balance - amount);
        return #ok();
    };

    public shared ({ caller }) func transfer(from : Principal, to : Principal, amount : Nat) : async Result<(), Text> {
        let balanceFrom = Option.get(tcnledger.get(from), 0);
        let balanceTo = Option.get(tcnledger.get(to), 0);
        if (balanceFrom < amount) {
            return #err("Insufficient balance to transfer");
        };
        tcnledger.put(from, balanceFrom - amount);
        tcnledger.put(to, balanceTo + amount);
        return #ok();
    };

    public query func balanceOf(owner : Principal) : async Nat {
        return (Option.get(tcnledger.get(owner), 0));
    };

    public query func totalSupply() : async Nat {
         var total = 0;
        for (balance in tcnledger.vals()) {
            total += balance;
        };
        return total;
    };

  let dao = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
  public shared ({ caller }) func registerMember(username: Text, bio: Text) : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (null) {
                // Proceed with registration as the member does not exist
                let newMember : Member = {
                    username = username;
                    bio = bio;
                    capsules = []; // Initialize with an empty list of capsules
                };
                // Add the new member to the registry
                dao.put(caller, newMember);
                // Airdrop tokens to the new member and handle the result
                switch (await mint(caller, 10)) {
                    case (#ok) {
                        return #ok();
                    };
                    case (#err(errMsg)) {
                        return #err("Error minting tokens from faucet: " # errMsg);
                    };
                };
            };
            case (_) {
                // Return an error if the member already exists
                return #err("Member already exists");
              };
      };
  };
  var nextProposalId : Nat64 = 0;
  let proposals = HashMap.HashMap<ProposalId, Proposal>(0, Nat64.equal, Nat64.toNat32);
  public shared ({ caller }) func createProposal(content: ProposalContent) : async Result<ProposalId, Text> {
    // Check if the caller is a registered member
    switch (dao.get(caller)) {
        case (null) {
            return #err("The caller is not a member - cannot create a proposal");
        };
        case (?member) {
            // Fetch the caller's token balance
            let balance: Nat = await balanceOf(caller);
            if (balance < 1) {
                return #err("The caller does not have enough tokens to create a proposal");
            };
            // Attempt to burn a token before creating the proposal
            switch (await burn(caller, 1)) {
                case (#ok) {
                    // Proceed with creating the proposal since the token burn was successful
                    let proposalId = nextProposalId;
                    let proposal: Proposal = {
                        id = nextProposalId;
                        content = content;
                        creator = caller;
                        created = Time.now();
                        executed = null;
                        votes = [];
                        voteScore = 0;
                        noVotes = 0;
                        yesVotes = 0;
                        status = #Open;
                    };
                    proposals.put(proposalId, proposal);
                    nextProposalId += 1; // Increment the proposal ID for the next proposal
                    return #ok(proposalId);
                };
                case (#err(_)) {return #err("Failed to burn tokens");};
                };
            };
        };
    };
    public query func getProposal(proposalId : ProposalId) : async ?Proposal {
        return proposals.get(proposalId);
    };
    public query func getAllProposals() : async [Proposal] {
        return Iter.toArray(proposals.vals());
    };
    private func _executeProposal(content : ProposalContent) : () {
        switch (content) {
            case (#ChangeManifesto(newManifesto)) {
                manifesto := newManifesto;
            };
            case (#AddGoal(newGoal)) {
                goals.add(newGoal);
            };
            case(#FeatureRequest(newRequest)) {
                requests.add(newRequest);
            };
        };
        return;
    };
    private func _hasVoted(proposal : Proposal, member : Principal) : Bool {
        return Array.find<Vote>(
            proposal.votes,
            func(vote : Vote) {
                return vote.member == member;
            },
        ) != null;
    };
    public shared ({ caller }) func voteProposal(proposalId : ProposalId, vote : Vote) : async Result<(), Text> {
        // Check if the caller is a member of the DAO
        switch (dao.get(caller)) {
            case (null) {
                return #err("The caller is not a member - canno vote one proposal");
            };
            case (?member) {
                // Check if the proposal exists
                switch (proposals.get(proposalId)) {
                    case (null) {
                        return #err("The proposal does not exist");
                    };
                    case (?proposal) {
                        // Check if the proposal is open for voting
                        if (proposal.status != #Open) {
                            return #err("The proposal is not open for voting");
                        };
                        // Check if the caller has already voted
                        if (_hasVoted(proposal, caller)) {
                            return #err("The caller has already voted on this proposal");
                        };
                        let votingPower = await balanceOf(caller);
                        let totalVotingPower = await totalSupply();
                        var newYesVotes = proposal.yesVotes;
                        var newNoVotes = proposal.noVotes;
                        switch (vote.yesOrNo) {
                            case (true) { newYesVotes += votingPower;  };
                            case (false) { newNoVotes += votingPower; };
                        };
                        let newVoteScore = proposal.voteScore + votingPower;
                        let requiredMajority = totalVotingPower / 2 +1;
                        var newExecuted : ?Time.Time = null;
                        let newVotes = Buffer.fromArray<Vote>(proposal.votes);
                        let newStatus = if (proposal.yesVotes >= requiredMajority) {
                            #Accepted;
                        } else if (proposal.noVotes >= requiredMajority) {
                            #Rejected;
                        } else {
                            #Open;
                        };
                        switch (newStatus) {
                            case (#Accepted) {
                                _executeProposal(proposal.content);
                                newExecuted := ?Time.now();
                            };
                            case (_) {};
                        };
                        let newProposal : Proposal = {
                            id = proposal.id;
                            content = proposal.content;
                            creator = proposal.creator;
                            created = proposal.created;
                            executed = newExecuted;
                            votes = Buffer.toArray(newVotes);
                            voteScore = newVoteScore;
                            yesVotes = newYesVotes;
                            noVotes = newNoVotes;
                            status = newStatus;
                        };
                        proposals.put(proposal.id, newProposal);
                        return #ok();
                    };
                };
            };
        };
    };
};
