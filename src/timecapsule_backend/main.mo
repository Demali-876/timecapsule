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
  type ShareableMember = Types.ShareableMember;
  type SharedTimeCapsule = Types.SharedTimeCapsule;
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
    public shared query func getGoals() : async [Text] {
        Buffer.toArray(goals);
    };
    public shared query func getRequests() : async [Text] {
        Buffer.toArray(requests);
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
    func _hasVoted(proposal : Proposal, member : Principal) : Bool {
        return Array.find<Vote>(
            proposal.votes,
            func(vote : Vote) {
                return vote.member == member;
            },
        ) != null;
    };
     func _executeProposal(content : ProposalContent) : () {
        switch (content) {
            case (#ChangeManifesto(newManifesto)) {
                manifesto := newManifesto;
            };
            case (#AddGoal(newGoal)) {
                goals.add(newGoal);
            };
            case(#FeatureRequest(newRequest)){
                requests.add(newRequest);
            };
        };
        return;
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
                let newMember : Member = {
                    username = username;
                    bio = bio;
                    capsules = Buffer.Buffer<TimeCapsuleId>(0);
                    following = Buffer.Buffer<TimeCapsuleId>(0);
                };
                dao.put(caller, newMember);
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
                return #err("Member already exists");
              };
      };
    };
    public shared ({ caller }) func updateMember(bio: Text, username: Text) : async Result<(), Text> {
    switch (dao.get(caller)) {
        case (null){
            return #err("Member does not exist");
        };
        case (?member){
            let updatedMember = {
                bio = bio;
                username = username;
                capsules = member.capsules;
                following = member.following;
            };
            dao.put(caller, updatedMember);
            return #ok();
            };
        };
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch (dao.get(caller)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?member) {
                dao.delete(caller);
                return #ok();
            };
        };
    };
    public query func getMember(p: Principal) : async Result<ShareableMember, Text> {
    switch (dao.get(p)) {
        case (null) {
            return #err("Member does not exist");
        };
        case (?member) {
            // Convert the Member instance to a ShareableMember
            let shareableMember = {
                username = member.username;
                bio = member.bio;
                capsules = Buffer.toArray(member.capsules);
                following = Buffer.toArray(member.following);
            };
            return #ok(shareableMember);
            };
        };
    };

    public query func getAllMembers() : async [ShareableMember] {
    let shareableMembers : [ShareableMember] = Array.map(
        Iter.toArray(dao.vals()),
        func (member : Member) : ShareableMember {
            return {
                username = member.username;
                bio = member.bio;
                capsules = Buffer.toArray<TimeCapsuleId>(member.capsules);
                following = Buffer.toArray<TimeCapsuleId>(member.following);
            };
        }
    );
    return shareableMembers;
    };


    public query func numberOfMembers() : async Nat {
        return dao.size();
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
                    nextProposalId += 1;
                    return #ok(proposalId);
                };
                case (#err(_)) {return #err("Failed to burn tokens");};
                };
            };
        };
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
                        }else {
                            switch(_hasVoted(proposal, caller)){
                                case(true) {
                                    return #err("The caller has already voted on this proposal");
                                };
                                case(false) {
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
                            proposal with
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
        };
    };
    public query func getAllProposals() : async [Proposal] {
        return Iter.toArray(proposals.vals());
    };

    var nextCapsuleId : Nat64 = 0;
    let capsuleLedger = HashMap.HashMap<TimeCapsuleId, TimeCapsule>(0, Nat64.equal, Nat64.toNat32);
    public shared ({ caller }) func createCapsule(content: TimeCapsuleContentType, unlockDate: UnlockDate) : async Result<TimeCapsuleId, Text> {
        switch(dao.get(caller)){
            case(null){
                return #err("The caller is not a member - cannot create a Capsule");
            };
            case(?member){
                let tokenbalance = await balanceOf(caller);
                if (tokenbalance < 1){
                    return #err("Not enough tokens to create a Capsule");
                };
                switch(await burn(caller,1)){
                    case(#ok){
                        let capsuleId = nextCapsuleId;
                        let capsule : TimeCapsule ={
                            id = nextCapsuleId;
                            content = content;
                            owner = caller;
                            unlockDate = Time.now() + (unlockDate * 1_000_000_000);
                            created = Time.now();
                            followers = Buffer.Buffer<Principal>(0);
                        };
                        capsuleLedger.put(capsuleId, capsule);
                        member.following.add(capsuleId);
                        member.capsules.add(capsuleId);
                        nextCapsuleId += 1;
                        return #ok(capsuleId);
                    };
                    case (#err(_)){return #err("Failed to burn Tokens and create capsule");};
                };
            };
        };
    };
    public shared({caller}) func transferCapsule(capsuleId: TimeCapsuleId, to: Principal) : async Result<TimeCapsuleId, Text> {
        switch (dao.get(caller)) {
            case (null) {
                return #err("The caller is not a member - cannot initiate transfer");
            };
            case (?member) {
                switch (capsuleLedger.get(capsuleId)) {
                    case (null) {
                    return #err("Capsule does not exist");
                    };
                    case (?capsule){
                        switch (capsule.owner == caller){
                            case(true){
                                let tokenBalance = await balanceOf(caller);
                                if (tokenBalance < 1) {
                                    return #err("Not enough tokens to complete the transfer");
                                };
                                switch (await burn(caller, 1)) {
                                    case (#ok) {
                                        let updatedCapsule = {
                                            id = capsule.id;
                                            content = capsule.content;
                                            owner = to; // New owner
                                            unlockDate = capsule.unlockDate;
                                            created = capsule.created;
                                            followers = capsule.followers;
                                        };
                                        capsuleLedger.put(capsuleId, updatedCapsule);
                                    return #ok(capsuleId);
                                    };
                                    case (#err(_)) {
                                    return #err("Failed to burn token for transfer");
                                    };
                                };
                            };
                            case(false){
                            return #err("Caller does not own the capsule - cannot transfer");
                            };
                        };
                    };
                };
            };
        };
    };

    public query func getCapsule(id: TimeCapsuleId): async ?SharedTimeCapsule {
    let maybeCapsule = capsuleLedger.get(id);
    switch (maybeCapsule) {
        case (null) {
            return null;
        };
        case (?capsule) {
            return ?{
                id = capsule.id;
                content = capsule.content;
                owner = capsule.owner;
                unlockDate = capsule.unlockDate;
                created = capsule.created;
                followers = Buffer.toArray(capsule.followers); 
                };
            };
        };
    };

    public query func getAllCapsules() : async [SharedTimeCapsule] {
    let capsules = Iter.toArray(capsuleLedger.vals());
    let shareableCapsules : [SharedTimeCapsule] = Array.map(capsules, func (capsule: TimeCapsule) : SharedTimeCapsule {
        return {
            id = capsule.id;
            content = capsule.content;
            owner = capsule.owner;
            unlockDate = capsule.unlockDate;
            created = capsule.created;
            followers = Buffer.toArray(capsule.followers);
        };
    });
    return shareableCapsules;
    };
    public shared ({ caller }) func updateCapsule(capsuleId: TimeCapsuleId, newContent: TimeCapsuleContentType, newUnlockDate: UnlockDate) : async Result<(), Text> {
    switch (capsuleLedger.get(capsuleId)) {
        case (null) {
            return #err("Capsule does not exist");
        };
        case (?capsule) {
            if (caller != capsule.owner) {
                return #err("Only the owner can update the capsule");
            };
            let updatedCapsule = {
                id = capsule.id;
                content = newContent;
                owner = capsule.owner; 
                unlockDate = newUnlockDate;
                created = capsule.created; 
                followers = capsule.followers; 
            };
            capsuleLedger.put(capsuleId, updatedCapsule);
            return #ok();
            };
        };
    };

    public shared({caller}) func followCapsule(capsuleId: TimeCapsuleId) : async Result<(), Text> {
    switch(dao.get(caller)) {
        case (null) {
            return #err("The caller is not a member - cannot follow the capsule");
        };
        case (?member) {
            switch(capsuleLedger.get(capsuleId)) {
                case (null) {
                    return #err("Capsule does not exist");
                };
                case (?capsule) {
                    let alreadyFollowing = Array.find<TimeCapsuleId>(Buffer.toArray(member.following),func (id : TimeCapsuleId) : Bool { id == capsuleId }) != null;

                    if (alreadyFollowing) {
                        return #err("Already following this capsule");
                    } else {
                        member.following.add(capsuleId);
                        capsule.followers.add(caller);
                        return #ok();
                        };
                    };
                };
            };
        };
    };


    public shared({caller}) func lockCapsule(capsuleId: TimeCapsuleId, duration: Int) : async Result<(), Text> {
    switch (capsuleLedger.get(capsuleId)) {
        case (null) {
            return #err("Capsule does not exist");
        };
        case (?capsule) {
            if (caller != capsule.owner) {
                return #err("Only the owner can lock the capsule");
            };
            let newUnlockDate = Time.now() + (duration * 1_000_000_000); // Convert seconds to nanoseconds
            if (newUnlockDate <= capsule.unlockDate) {
                return #err("New unlock date must be greater than the current unlock date");
            };
            let updatedCapsule = {
                capsule with
                unlockDate = newUnlockDate;
            };
            capsuleLedger.put(capsuleId, updatedCapsule);
            return #ok();
            };
        };
    };

    public shared({caller})func unlockCapsule(capsuleId: TimeCapsuleId) : async Result<(), Text> {
    switch (capsuleLedger.get(capsuleId)) {
        case (null) {
            return #err("Capsule does not exist");
        };
        case (?capsule) {
            if (caller != capsule.owner) {
                return #err("Only the owner can unlock the capsule");
            };
            if (Time.now() < capsule.unlockDate) {
                return #err("Capsule is locked");
            } else {
                let updatedCapsule = {
                capsule with
                unlockDate = Time.now(); // Set unlock date to now, making it accessible
                };
                capsuleLedger.put(capsuleId, updatedCapsule);
                return #ok();
                };
            };
        };
    };
};
