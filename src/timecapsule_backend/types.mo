import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
module {
    public type Result<Ok, Err> = Result.Result<Ok, Err>;
    public type HashMap<K, V> = HashMap.HashMap<K, V>;

    /////////////
    // Member //
    ////////////
    public type Member = {
        username: Text;
        bio : Text;
        capsules: [TimeCapsuleId];
    };

    ///////////////////
    // Time Capsule //
    //////////////////
    public type TimeCapsuleId = Nat64;
    public type UnlockDate = Time.Time;

    public type TimeCapsuleContentType = {
    #PlainText: Text;
    #StructuredText: StructuredContent;
    #Link: Text; // Could be used to reference external content or resources
    };

    public type StructuredContent = {
    title: Text;
    body: Text;
    tags: [Text]; // Optional tags for categorization or search
    };

    public type TimeCapsule = {
        id: TimeCapsuleId;
        content: TimeCapsuleContentType; // Encrypted content
        owner: Principal;
        unlockDate: UnlockDate;
        created: Time.Time;
    };

    ///////////////////
    // Proposal //
    //////////////////

    public type ProposalId = Nat64;
    public type ProposalContent = {
        #ChangeManifesto: Text; // Change the manifesto to the provided text
        #AddGoal: Text; // Add a new goal with the provided text
        #FeatureRequest: Text; //Request a specific feature
    };
    public type ProposalStatus = {
        #Open;
        #Accepted;
        #Rejected;
    };
    
    public type Proposal = {
        id: ProposalId; // The id of the proposal
        content: ProposalContent; // The content of the proposal
        creator: Principal; // The member who created the proposal
        created: Time.Time; // The time the proposal was created
        executed: ?Time.Time; // The time the proposal was executed or null if not executed
        votes: [Vote]; // The votes on the proposal so far
        voteScore: Nat; // A score based on the votes
        yesVotes: Nat;
        noVotes: Nat;
        status: ProposalStatus; // The current status of the proposal
    };
    
    public type Vote = {
        member: Principal; // The member who voted
        votingPower: Nat;
        yesOrNo: Bool; // true = yes, false = no
    };
    
};
