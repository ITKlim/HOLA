import UIKit
import MessageKit
import InputBarAccessoryView



class ChatViewController: MessagesViewController {
    
    let selfSender = Sender(senderId: "1", displayName: "Me")
    let otherSender = Sender(senderId: "2", displayName: "")
    
    var chatID: String?
    var otherID: String?
    var service = Servise.shared
    var selfAvatar: Avatar?
    var otherAvatar: Avatar?
    var otherImageURL: String?
    var selfImage: UIImageView?
    var otherImage: UIImageView?
    var user = User()
    var otherUser = User()
    var messages = [Message]()
    var documentIsExists = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Connectivity.isConnectedToInternet() {
            alertInternetConnection()
        }
        
        if let otherImageURL = otherImageURL {
            self.service.fetchUserAvatar(url: otherImageURL) { image in
                self.setBarButtonItem(contactName: self.user.name, contactMail: self.user.email, contactImage: image)
            }
        }
        setupMessageCollectionView()
    }
    
    func getMessages(convoId: String) {
        
        service.getAllMessages(chatId: convoId) { [weak self] messages in
            guard let self = self else { return }
            self.messages = messages
            self.reloadData()
        }
    }
    
    func setBarButtonItem(contactName: String?, contactMail: String?, contactImage: UIImageView?) {
        
        let customTitleView = createCustomTitleView(
            contactName: (contactName ?? contactMail) ?? "no Name",
            contactMail: contactMail ?? "no Mail",
            contactImage: contactImage ?? UIImageView(image: UIImage(named: "unnamed"))
        )
        
        navigationItem.titleView = customTitleView
        
    }
    
    private func setupMessageCollectionView() {
        self.setBarButtonItem(contactName: user.name, contactMail: user.email, contactImage: user.avatarImage)
        
        customMessageInputBar()
        selfAvatar = getAvatarFor(senderId: "1", image: selfImage)
        otherAvatar = getAvatarFor(senderId: "2", image: otherImage)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        setMessageStyle()
        
        messageInputBar.delegate = self
        showMessageTimestampOnSwipeLeft = true
        
        if let chatID = chatID {
            self.getMessages(convoId: chatID)
        } else {
            service.getConvoId(otherID: otherID!) { [weak self] chatId in
                self?.chatID = chatId
                self?.getMessages(convoId: chatId)
            }
        }
    }
    
    private func customMessageInputBar() {
        // создаем кастомную кнопку
        messageInputBar.sendButton.title = "Отпр."
        
    }
    
    private func reloadData() {
        self.messagesCollectionView.reloadData { [weak self] in
            guard let self = self else { return }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
            if self.messagesCollectionView.contentSize.height > self.messagesCollectionView.frame.height {
                self.messagesCollectionView.contentOffset = .init(x: self.messagesCollectionView.contentOffset.x, y: self.messagesCollectionView.contentOffset.y + 5)
            } else {
                self.messagesCollectionView.contentOffset = .init(x: self.messagesCollectionView.contentOffset.x, y: self.messagesCollectionView.contentOffset.y - 10)
            }
        }
    }
    
    private func getAvatarFor(senderId: String, image: UIImageView?) -> Avatar? {
        if senderId == "1" {
            return Avatar(image: image?.image, initials: "1")
        } else if senderId == "2" {
            return Avatar(image: image?.image, initials: "2")
        } else {
            return Avatar(image: UIImage(named: "unnamed"), initials: "")
        }
    }
    
    private func setMessageStyle() {
        let layout = MessagesCollectionViewFlowLayout()
        layout.setMessageIncomingAvatarSize(.zero) // скрыть аватар при входящем сообщении
        layout.setMessageOutgoingAvatarSize(.zero) // скрыть аватар при исходящем сообщении
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: .zero)) // выровнять текст входящих сообщений по левому краю
        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero)) // выровнять текст исходящих сообщений по правому краю
        messagesCollectionView.collectionViewLayout = layout
    }
    
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func alertDocumentDoesNotExist() {
        let alertController = UIAlertController(title: "Диалог был удален", message: "Диалог отсутствует либо, удален другим пользователем", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Extensions for Chat

extension ChatViewController:  MessagesDisplayDelegate, MessagesLayoutDelegate, MessagesDataSource  {
    
    var currentSender: MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .systemBlue : .systemGray6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        
        avatarView.isHidden = true
    }
    
    
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    
}



extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard Connectivity.isConnectedToInternet() else { return alertInternetConnection()
        }
        inputBar.sendButton.isEnabled = false
        inputBar.inputTextView.text = nil
        
        let msg = Message(sender: self.selfSender, messageId: "", sentDate: Date(), kind: .text(text))
        
        messages.append(msg)
        service.sendMessage(otherID: self.otherID, convoID: self.chatID, text: text) { [weak self] convoId in
            guard let self = self else { return }
            DispatchQueue.main.async {
                inputBar.inputTextView.text = nil
                
                self.reloadData()
            }
            
            self.chatID = convoId
            
        }
    }
    
    
    
}
