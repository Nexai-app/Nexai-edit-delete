import Bool "mo:base/Bool";
import CompanyHashMap "mo:base/Array";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

shared ({caller}) actor class Nexai() = {
  // variables
  var companies : [CompanyEntry] = [];
  var cards : [CardEntry] = [];
  var newCard : [CardEntry] = [];
  var updatedCard : [CardEntry] = [];
  private stable var companyId : Nat = 1000;
  stable var cardId : Nat = 1;
  var CompanyHashMap : HashMap.HashMap<Principal, CompanyEntry> = HashMap.HashMap<Principal, CompanyEntry>(10, Principal.equal, Principal.hash);
  var CardHashMap : HashMap.HashMap<Nat, CardEntry> = HashMap.HashMap<Nat, CardEntry>(1, Nat.equal, Hash.hash);
  

   

// add companies (info of the company)
   public type CompanyEntry = {
        name : Text;
        email : Text;
        createdAt : Int;
        // onBoarding : Bool;
        // isAdmin : Bool;
    };
    stable var startTime = Time.now()/ 1000000000;
    /* we're dividing by 1e9 because we're converting from nanoseconds to seconds. PS we have to reset the timer. */
    // Debug.print(debug_show(startTime));

    // add cards (custom questions that the company can ask)
    public type CardEntry = {
        email : Text;
        question : Text; /*P how do i transfer my btc from my wallet*/
        answer : Text;/* just sleep and your btc would be transfered*/
    };

    func _makeCompany(name : Text, email : Text, createdAt : Int) : CompanyEntry {
    {
      name : Text;
      email : Text;
      createdAt : Int;
    };
  };

    //CREATE FUNCTIONS
    public func createCompany(name : Text, email : Text, createdAt : Int) : async Bool {
      var companyExists : Bool = false;

        for ((i,j) in CompanyHashMap.entries()) {
        if (j.email == email) {
          companyExists := true;
          throw Error.reject("There's an existing user with this email, please choose another email.");
          return companyExists;
        };
      };

      if (companyExists == false) {
        let newCompany = _makeCompany (name, email, startTime);
        CompanyHashMap.put(caller, newCompany);
        var newCompanies = Array.append(companies, [newCompany]);
        companyExists := true;
        companies := newCompanies; 
        
        Debug.print("Success!...Company created.");
        
        if(companies != newCompanies) {
          Debug.print("Something went wrong!!");
        } 
        else {
          companyId := companyId + 1;
          Debug.print("Company ID: " # debug_show(companyId) # ".");
        };
      };

        return companyExists;
    };


    public shared func createQCard (email: Text, question: Text, answer: Text) : async CardEntry {
      var newCard : CardEntry = {email = email; question = question; answer = answer};
      CardHashMap.put(cardId, newCard);
      var allCards = Array.append(cards, [newCard]);  // Array.append id deprecated and will be discontinued in future versions
      cards := allCards;

      Debug.print("You have created a new card for your company!");

      if (cards != allCards) {
        Debug.print("something went wrong!");
      }
      else{
        cardId := cardId + 1;
        Debug.print("New Card ID: " # debug_show(cardId) # ".");
      };
      return(newCard);
    };


    public shared query ({ caller }) func fetchCardById (cardId: Nat) :async ?CardEntry {
      var match = CardHashMap.get(cardId);
      var updatedCard : [CardEntry]  = [];

      switch (match) {
        case(null) {return null};
        case(?match) {
          return ?match;
        };
      };
    }; 

    public shared func editQCard (cardId: Nat, email : Text, updatedQuestion: Text, updatedAnswer: Text): async CardEntry{
    var updatedCard = CardHashMap.get(cardId);
    var newCard : CardEntry = {email = email; question = updatedQuestion; answer = updatedAnswer};
    CardHashMap.put(cardId, newCard);
    return (newCard);
    };

    public shared func deleteQCard (cardId: Nat): async () {
    var x = CardHashMap.delete(cardId);
    return ();
    };
   
   
   // GET query FUNCTIONS
   // NOW WE HAVE TO COFIGURE THIS WITH HASH MAP
    public query func getCompanyId() : async Principal {
      Debug.print(debug_show(caller));
      return (caller);
    };
    public query func getCompaniesArray() : async ([CompanyEntry]) {
      return companies;
      
    };
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CHECK:TO SYNC WITH CARDHASHMAP
    public query ({ caller }) func getAllQCards() : async ?[CardEntry] {
    do ? {
      var buff = Buffer.Buffer<CardEntry>(0);
      for ((i, j) in CardHashMap.entries()) {
          buff.add(j);
      };
      buff.toArray();

    };
  };
    
   
    };
  






  // IDEAS & FUNCTIONS
  // createCompany( name, email, createdAt, Identity)                                                >>>>>>>
  // createQCard( email, question, answer, Principal, hashmaps )                                     >>>>>>>
  // editQCard( question, answer, *cardId* use cardId to find the card, then replace the feeds )     -------
  // deleteQCard ( Principal )                                                                       -------
  // uploadCompanyPDF( .)                                                                            XXXXXXX
  // getCompanyStatistics ( users, daily sign up, active time of the day )                           XXXXXXX

  // set up => internet identity for companies
  // => counter
  // => principal
  // => hashmaps also


