//
//  Service.swift
//  HOLY
//
//  Created by Клим Бакулин on 13.12.2022.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit
import FirebaseStorage

class Servise {
    
    static let shared = Servise()
    
    init() {}
    
    //MARK: --Messenger Strart App

    
    func createNewUser(_ data: LoginField, completion: @escaping (Result <Any, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: data.email, password: data.password) { result, error in
            if error == nil {
                if result != nil {
                    
                    _ = result?.user.uid
                    _ = data.email
                    //let data: [String: Any] = ["email":email]
                    //Firestore.firestore().collection("users").document(userId!).setData(data)
                    completion(.success(""))
                }
                
            } else {
                guard let error = error else { return }
                completion(.failure(error))
            }
        }
    }
    
    func checkDocumentExists(documentName: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("conversations").document(documentName)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Документ существует")
                completion(true)
            } else {
                print("Документ не существует")
                completion(false)
            }
        }
    }
    
    
    func confirmEmail() {
        Auth.auth().currentUser?.sendEmailVerification( completion: { err in
            if err != nil {
                print(err!.localizedDescription)
                }
            }
        )
    }
    
    
    func authInApp(_ data: LoginField, completion: @escaping (AuthResponse) -> ()) {
        Auth.auth().signIn(withEmail: data.email, password: data.password) { result, err in
            
            
            if err != nil {
                completion(.error)
            } else {
                if let result = result {
                    if result.user.isEmailVerified {
                        let userId = result.user.uid
                        let email = data.email
                        let data: [String: Any] = ["email":email]
                        let docRef = Firestore.firestore().collection("users").document(userId)
                        
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                            } else {
                                Firestore.firestore().collection("users").document(userId).setData(data)
                            }
                            completion(.success)
                        }
                    } else {
                        self.confirmEmail()
                        completion(.noVerify)
                    }
                }
            }
        }
    }
    //MARK: - Messenger
    func getAllUsers(completion: @escaping ([User]) -> ()) {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        var currentUsers = [User]()
        
        Firestore.firestore().collection("users").whereField("email", isNotEqualTo: email).getDocuments { snap, err in
            if err == nil {
                if let docs = snap?.documents {
                    for doc in docs {
                        let data = doc.data()
                        let userId = doc.documentID
                        let email = data["email"] as! String
                        let name = data["name"] as? String
                        let dataAvatarURL = data["avatar"] as? String
                        
                        currentUsers.append(User(id: userId, email: email, name: name, avatarURL: dataAvatarURL))
                    }
                }
                completion(currentUsers)
            }
        }
    }
  
    
    func sendMessage(otherID: String?, convoID: String?, text: String, completion: @escaping (String)->()) {
        
        let ref = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid {
            if convoID == nil {
                //создаем новую переписку
                let convoID = UUID().uuidString
                
                let selfData: [String: Any] = [
                    "date": Date(),
                    "otherID": otherID!
                ]
                
                let otherData: [String: Any] = [
                    "date": Date(),
                    "otherID": uid
                ]
                
                ref.collection("users")
                    .document(uid)
                    .collection("conversations")
                    .document(convoID)
                    .setData(selfData)
                
                ref.collection("users")
                    .document(otherID!)
                    .collection("conversations")
                    .document(convoID)
                    .setData(otherData)
                
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": uid,
                    "text": text
                ]
                
                let convoInfo: [String: Any] = [
                    "date": Date(),
                    "selfSender": uid,
                    "otherSender": otherID!
                ]
                
                ref.collection("conversations")
                    .document(convoID)
                    .setData(convoInfo) { err in
                        if let err = err {
                            print(err.localizedDescription)
                            return
                        }
                        ref.collection("conversations")
                            .document(convoID)
                            .collection("messages")
                            .addDocument(data: msg) { err in
                                if err == nil {
                                    completion(convoID)
                                }
                            }
                    }
            } else {
                
                let msg: [String: Any] = [
                    "date": Date(),
                    "sender": uid,
                    "text": text
                    
                ]
                
                ref.collection("conversations").document(convoID!).collection("messages").addDocument(data: msg) { err in
                    if err == nil {
                        completion(convoID!)
                    }
                    
                }
            }
        }
    }
    
    
    func getConvoId(otherID: String, completion: @escaping (String)->()) {
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Firestore.firestore()
            
            ref.collection("users")
                .document(uid)
                .collection("conversations")
                .whereField("otherID", isEqualTo: otherID)
                .getDocuments { snap, err in
                    if err != nil {
                        return
                    }
                    
                    if let snap = snap, !snap.documents.isEmpty {
                        let doc = snap.documents.first
                        if let convoID = doc?.documentID{
                            completion(convoID)
                        }
                    }
                }
        }
    }
    
    func getSelfName(completion: @escaping (User)->()){
        
        if let email = Auth.auth().currentUser?.email {
            let uid = Auth.auth().currentUser?.uid
            let ref = Firestore.firestore()
            var currentUser = User(id: uid!, email: email)
            
            ref.collection("users")
                .whereField("email", isEqualTo: email)
                .getDocuments { snap, err in
                    if err == nil {
                        
                        if let docs = snap?.documents {
                            let data = docs.first
                            if let dataEmail = data!["email"] {
                                currentUser.email = dataEmail as? String
                            }
                            if let dataName = data!["name"] {
                                currentUser.name = (dataName as? String)
                            }
                            if let dataAvatar = data!["avatar"] {
                                currentUser.avatarURL = (dataAvatar as? String)
                            }
                        }
                        completion(currentUser)
                    }
                }
        }
    }
    
    
    
    
    
    // MARK: - Chat
    
    func getAllMessages(chatId: String, completion: @escaping ([Message]) -> ()) {
        if let uid = Auth.auth().currentUser?.uid {
            
            let ref = Firestore.firestore()
            ref.collection("conversations")
                .document(chatId)
                .collection("messages")
            //                    .limit(to: 100) // лимит
                .order(by: "date", descending: false)
                .addSnapshotListener { snap, err in
                    if err != nil {
                        return
                    }
                    if let snap = snap, !snap.documents.isEmpty {
                        var msgs = [Message]()
                        var sender = Sender(senderId: uid, displayName: "")
                        for doc in snap.documents {
                            let data = doc.data()
                            let userId = data["sender"] as! String
                            let messageId = doc.documentID
                            let date = data["date"] as! Timestamp
                            let sentDate = date.dateValue()
                            let text = data["text"] as! String
                            
                            if userId == uid {
                                sender = Sender(senderId: "1", displayName: "")
                            } else {
                                sender = Sender(senderId: "2", displayName: "")
                            }
                            msgs.append(Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: .text(text)))
                        }
                        completion(msgs)
                    }
                }
        }
        
    }
    
    
    func fetchChatListItem(completion: @escaping ([ChatListItem]) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var chatListItems = [ChatListItem]()
        chatListItems.removeAll()
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("conversations")
            .addSnapshotListener { snap, err in
                if err == nil {
                    
                    if let docs = snap?.documents {
                        
                        for doc in docs {
                            let chatID = doc.documentID
                            let otherID = doc["otherID"] as! String
                            chatListItems.append(ChatListItem.init(chatID: chatID, otherID: otherID))
                        }
                    }
                    completion(chatListItems)
                }
            }
    }
    
    func fetchChats(chatListItems: [ChatListItem], completion: @escaping ([Chat]) -> ()) {
        
        var result: [Chat] = []
        var isFirstFetch: Bool = true
       // guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !chatListItems.isEmpty else {
            completion([])
            return
        }
        for chat in chatListItems {
            let ref = Firestore.firestore()
            ref.collection("conversations")
                .document(chat.chatID ?? "")
                .collection("messages")
                .limit(to: 1) // лимит
                .order(by: "date", descending: true)
                .addSnapshotListener { snap, err in
                    if err != nil {
                    }
                    
                    if let snap = snap, !snap.documents.isEmpty {
                        for doc in snap.documents {
                            let data = doc.data()
                            let userId = data["sender"] as? String
                           // let messageId = doc.documentID
                            let date = data["date"] as? Timestamp
                            let sentDate = date?.dateValue()
                            let lastMessage = data["text"] as? String
                            let chatResult = Chat(lastMessage: lastMessage, date: sentDate, id: chat.chatID, otherID: chat.otherID, userID: userId)
                            if result.map({ $0.id }).contains(chat.chatID) == false {
                                result.append(chatResult)
                            } else {
                                result.append(Chat.init())
                            }
                            tryDoCompletion(chat: chatResult)
                        }
                    } else {
                        result.append(Chat.init())
                        tryDoCompletion(chat: nil)
                    }
                }
            
        }
        func tryDoCompletion(chat: Chat?) {
            if result.count == chatListItems.count {
                completion(result.filter({ $0.otherID != nil }).sorted())
                isFirstFetch = false
                result.removeAll()
                return
            } else if !isFirstFetch, let chat = chat {
                NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["chat": chat])
                result.removeAll()
                return
            } else if !isFirstFetch {
                result.removeAll()
                return
                
            } else {
            }
        }
    }
    
    func fetchOtherUserInfo(chatListItems: [Chat], completion: @escaping ([Chat]) -> ()) {
        var result: [Chat] = []
        var fetchedCount: Int = 0
        var isFirstFetch: Bool = true
        guard !chatListItems.isEmpty else {
            completion([])
            return
        }
        for chat in chatListItems {
            guard let chatOtherID = chat.otherID else {
                fetchedCount += 1
                continue
            }
            let ref = Firestore.firestore()
            ref.collection("users")
                .document(chatOtherID)
                .addSnapshotListener({ snap, err in
                    if err != nil {
                    }
                    if let snap = snap {
                        let data = snap.data()
                        let userEmail = data?["email"] as? String
                        let userName = data?["name"] as? String
                        let userAvatarURL = data?["avatar"] as? String
                        let chatResult = Chat(lastMessage: chat.lastMessage, date: chat.date, id: chat.id, otherID: chat.otherID, userID: chat.userID, email: userEmail, name: userName, avatarURL: userAvatarURL, avatarImage: nil)
                        result.append(chatResult)
                        tryDoCompletion(chat: chatResult)
                    }
                }
                )}
        tryDoCompletion(chat: nil)
        
        func tryDoCompletion(chat: Chat?) {
            if (fetchedCount + result.count) == chatListItems.count {
                completion(result.filter({ $0.otherID != nil }).sorted())
                isFirstFetch = false
                result.removeAll()
                return
            } else if !isFirstFetch, let chat = chat {
                NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["chat": chat])
                result.removeAll()
                fetchedCount = 0
                return
            } else {
            }
        }
    }
    
    
    func addInfo(info: OtherInfoOfUser, completion: @escaping (Result<Any, Error>)->()) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let name = info.name
        let ref = Firestore.firestore()
        ref.collection("users")
            .document(uid)
            .setData(["name" : name ?? ""], merge: true) { err in
                if err != nil {
                    print("Успешно добавлена информация")
                    completion(.success(()))
                }
                else {
                    guard let err = err else { return }
                    completion(.failure(err))
                }
            }
    }

    //MARK: - Fetch Image from Firebase storage
    
    func fetchUserChats(completion: @escaping ([Chat]) -> ()) {
        var chats = [Chat]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore()
        ref.collection("users")
            .document(uid)
            .collection("chats")
            .addSnapshotListener { snap, err in
                if err != nil {
                    print(err?.localizedDescription)
                }
                
                if let snap = snap, !snap.documents.isEmpty {
                    for doc in snap.documents {
                        let data = doc.data()
                        let userId = data["userId"] as? String
                        let otherId = data["otherId"] as? String
                        let email = data["email"] as? String
                        let name = data["name"] as? String
                        let chatId = data["chatId"] as? String
                        let date = data["date"] as? Timestamp
                        let sentDate = date?.dateValue()
                        let avatarURL = data["avatar"] as? String
                        let lastMessage = data["lastMessage"] as? String
                        
                        chats.append(Chat(lastMessage: lastMessage, date: sentDate, id: chatId, otherID: otherId, userID: userId, email: email, name: name, avatarURL: avatarURL, avatarImage: nil))
                    }
                }
                completion(chats)
            }
    }
    
    func uploadPhoto(image: UIImage, photoImageView: UIImageView, completion: @escaping (Result<URL, Error>)->()) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference().child("avatars").child(uid)
        guard let imageData = photoImageView.image?.jpegData(compressionQuality: 1) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        ref.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error  {
                completion(.failure(error))
                print("error", error.localizedDescription)
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                
                let db = Firestore.firestore()
                let documentRef = db.collection("users")
                    .document(uid)
                    .setData(["avatar" : url.absoluteString], merge: true) { error in
                        if error != nil {
                            print("Ошибка сохранения файла")
                        }
                        print("Файл успешно загружен")
                        completion(.success(url))
                    }
            }
            
        }
    }
    
    func getImageFromFirebaseAndCompare(currentUserURL: String?)  {
        
        guard currentUserURL != nil else { return }
        let storageRef = Storage.storage().reference(forURL: currentUserURL!)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = paths.appendingPathComponent("avatar.png")
        let fileData = try! Data(contentsOf: fileURL)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                return
            }
            
            if let imageData = data {
                if imageData == fileData {
                } else {
                }
            }
        }
    }
    
    func fetchUserAvatar(url: String, completion: @escaping (UIImageView?) -> Void) {
        let refstorage = Storage.storage().reference(forURL: url)
        let megabyte = Int64(5 * 1024 * 1024)
        refstorage.getData(maxSize: megabyte) { data, error in
            if let imageData = data, let image = UIImage(data: imageData) {
                completion(UIImageView(image: image))
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUsersAvatar(users: [User], completion: @escaping (Dictionary<String, UIImageView>) -> Void){
        var result: Dictionary<String, UIImageView> = [:]
        var fetchedCount: Int = 0
        print("adfafsdf start")
        for user in users {
            if let currentUserURL = user.avatarURL {
                fetchUserAvatar(url: currentUserURL, completion: { imageView in
                    if let id = user.id, !id.isEmpty, let imageView = imageView {
                        result[id] = imageView
                        fetchedCount += 1
                    } else {
                        fetchedCount += 1
                    }
                    tryDoCompletion()
                })
            } else {
                fetchedCount += 1
            }
        }
        tryDoCompletion()
        
        func tryDoCompletion() {
            if users.count == fetchedCount {
                completion(result)
            } else {
            }
        }
    }
    
//MARK: -//Delete convo
    
    func deletedDocumentMark(convoId: String, completion: @escaping (Error?) -> Void) {
       
        let ref = Firestore.firestore().collection("conversations").document(convoId)
        ref.setValue(true, forKey: "isDeleted")
        completion(nil)
//        ref.setData(["isDeleted": true]) { error in
//            if let error = error {
//                print("Error updating document: \(error)")
//                completion(error)
//            } else {
//                print("Document updated successfully")
//                completion(nil)
//            }
//        }
    }
    
    
    func deletedDocumentMark2(convoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = Firestore.firestore().collection("conversations").document(convoId)
        
        ref.updateData(["isDeleted": true]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Document updated successfully")
                completion(.success(()))
            }
        }
    }


    
    func deleteConversation(convoId: String, completion: @escaping () -> Void) {
        let ref = Firestore.firestore()
        ref.collection("conversations")
            .document(convoId)
            .delete { err in
                if let err = err {
                    print("Ошибка удаления диалога \(err.localizedDescription)")
                } else {
                    print("Успешное удаление")
                }
                completion()
            }
    }
    
    func deleteConversationFromUserDocument(convoId: String) {
        let ref = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.collection("users")
            .document(uid)
            .collection("conversations")
            .document(convoId)
            .delete { err in
                if let err = err {
                    print("Ошибка удаления диалога \(err.localizedDescription)")
                } else {
                    print("Успешное удаление")
                }
            }
    }
    
    func deleteConversationFromOtherUserDocument(otherID: String, convoId: String) {
        let ref = Firestore.firestore()
        ref.collection("users")
            .document(otherID)
            .collection("conversations")
            .document(convoId)
            .delete { err in
                if let err = err {
                    print("Ошибка удаления диалога \(err.localizedDescription)")
                } else {
                    print("Успешное удаление")
                }
            }
    }
    
}
