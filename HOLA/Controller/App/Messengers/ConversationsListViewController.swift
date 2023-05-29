import UIKit
import InputBarAccessoryView

class ConversationsListViewController: UIViewController {
    
    let service = Servise.shared
    var chats = [Chat]()
    var newChats = [Chat]()
    var activityIndicator = UIActivityIndicatorView()
    var isFetching: Bool = false
        
    
    private let refreshControl = CustomRefreshControl(frame: .zero)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        if !Connectivity.isConnectedToInternet() {
            alertInternetConnection()
            activityIndicator.startAnimating()
        }
        setupTableView()
        fetchChats()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessage(_:)), name: .didReceiveMessage, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchChats()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: ChatTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    func fetchChats() {
        guard !isFetching else { return }
        isFetching = true
        self.service.fetchChatListItem { [weak self] chatListItems in
            guard let self = self else { return }
            if chatListItems.isEmpty {
                self.alertCheckFirstConversation()
            }
            self.service.fetchChats(chatListItems: chatListItems, completion: { [weak self] chats in
                guard let self = self else { return }
                self.chats = chats
                self.service.fetchOtherUserInfo(chatListItems: self.chats) { [weak self] otherUserInfo in
                    guard let self = self else { return }
                    var otherUserInfo = otherUserInfo
                    for (index, value) in otherUserInfo.enumerated() {
                        if let oldChat = self.newChats.first(where: { $0.otherID == value.otherID }), let imageView = oldChat.avatarImage, oldChat.avatarURL == value.avatarURL {
                            otherUserInfo[index].avatarImage = imageView
                        }
                    }
                    self.newChats = otherUserInfo
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.isFetching = false
                    
                    let users = otherUserInfo.map({ User.init(id: $0.otherID, email: $0.email, name: $0.name, avatarURL: $0.avatarURL, avatarImage: $0.avatarImage )}).filter({ $0.avatarURL != nil })
                    
                    self.service.fetchUsersAvatar(users: users) { [weak self] result in
                        
                        guard let self = self else { return }
                        var chats = self.newChats
                        result.forEach({ resultItem in
                            if let index = chats.firstIndex(where: { $0.otherID == resultItem.key }) {
                                chats[index].avatarImage = resultItem.value
                            }
                        })
                        self.newChats = chats
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    
    
    
    
    private func converStingToDate(date: Date)-> (String,String) {
        let dayOfMonth = DateFormatter()
        let time = DateFormatter()
        //dateF.timeStyle = .full
        dayOfMonth.dateFormat = "dd.MM"
        time.dateFormat = "HH:mm"
        let tempDayOfMonth = dayOfMonth.string(from: date)
        let temptime = time.string(from: date)
        return (tempDayOfMonth, temptime)
    }
    
    //MARK: - Alert
    
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func alertCheckFirstConversation() {
        let alertController = UIAlertController(title: "У вас еще нет диалогов!", message: "Чтобы начать свой первый диалог перейдите на вкладку пользователи и кликните на собеседника для общения 😌", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func alertWarningDeleteConversation() {
        let alertController = UIAlertController(title: "Вы точно хотите удалить этот диалог?", message: "Диалог после удаления невозможно будет восстановить", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Constraint
    
    private func setupConstraintsActivityIndicator() {
        tableView.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    @objc
    private func refresh(_ sender: UIRefreshControl) {
        fetchChats()
    }
    
    @objc
    private func didReceiveMessage(_ sender: Notification) {
        fetchChats()
    }
    
}

//MARK: - Extensions ConversationsListViewController

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newChats.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.reuseId, for: indexPath) as! ChatTableViewCell
        
        if indexPath.row < newChats.count {
            let chat = newChats[indexPath.row]
            
            if chat.date != nil {
                let date = converStingToDate(date: chat.date!)
                cell.configCell(email: chat.email, name: chat.name, message: chat.lastMessage, date: date, avatar: chat.avatarImage)
            } else {
                cell.configCell(email: chat.email, name: chat.name, message: chat.lastMessage, date: nil, avatar: chat.avatarImage)
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
        let chat = newChats[indexPath.row]
        guard let chatID = chat.id, let otherID = chat.otherID else { return }
        vc.chatID = chatID
        vc.otherID = otherID
        vc.user.email = chat.email
        vc.user.name = chat.name
        vc.user.avatarImage = chat.avatarImage
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Вы точно хотите удалить этот диалог?", message: "Диалог после удаления невозможно будет восстановить!", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            let chat = self.newChats[indexPath.row]
            guard let chatID = chat.id, let otherId = chat.otherID else { return }
            if editingStyle == .delete {
                // Выполняем код в фоновом потоке
                DispatchQueue.global(qos: .userInitiated).async {
                    self.service.deleteConversationFromUserDocument(convoId: chatID)
                    self.service.deleteConversationFromOtherUserDocument(otherID: otherId, convoId: chatID)
                    self.service.deleteConversation(convoId: chatID) {
                        // Выполняем обновление пользовательского интерфейса в главном потоке
                        DispatchQueue.main.async {
                            self.fetchChats()
                        }
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Удалить"
    }
    
}


extension ConversationsListViewController: InputBarAccessoryViewDelegate {
    
    
}


