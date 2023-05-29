//
//  UserViewController.swift
//  HOLY
//
//  Created by Клим Бакулин on 19.12.2022.
//

import UIKit


class UsersViewController: UIViewController {
    
    let service = Servise.shared
    var activityIndicator = UIActivityIndicatorView()
    var users = [User]()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var isFetching = false
    private let refreshControl = CustomRefreshControl(frame: .zero)
    private let search = UISearchController(searchResultsController: nil)
    private var searchString: String? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraintsActivityIndicator()
        activityIndicator.startAnimating()
        if !Connectivity.isConnectedToInternet() {
            alertInternetConnection()
            activityIndicator.stopAnimating()
        }
        setupTableView()
        fetchUsers()
        setupSearchBar()
    }
    
    private func setupTableView() {
        guard let tableView = tableView else { return }
        tableView.register(UINib(nibName: "UserCellTableViewCell", bundle: nil), forCellReuseIdentifier: UserCellTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    private func setupSearchBar() {
        search.delegate = self
        search.searchBar.delegate = self
        search.searchBar.placeholder = "Поиск"
        search.searchBar.keyboardType = .emailAddress
        self.navigationItem.searchController = search
    }
    
    //
    private func fetchUsers() {
        guard !isFetching else {
            refreshControl.endRefreshing()
            return
        }
        isFetching = true
        self.service.getAllUsers { [weak self] users in
            guard let self = self else { return }
            self.users = users
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.isFetching = false
            self.fetchAvatars()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func fetchAvatars() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            let users = self.users.filter({ $0.avatarURL != nil })
            self.service.fetchUsersAvatar(users: users, completion: { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    var newUsers = self.users
                    result.forEach({ resultItem in
                        if let index = newUsers.firstIndex(where: { $0.id == resultItem.key }) {
                            newUsers[index].avatarImage = resultItem.value
                        }
                    })
                    self.users = newUsers
                    self.tableView.reloadData()
                }
            })
        }
       
    }
    
    private func setupConstraintsActivityIndicator() {
        view.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func getFilteredUsers() -> [User] {
        guard let searchString = searchString, !searchString.isEmpty else {
            return self.users
        }
        let result = users.filter({
            return $0.email!.contains(searchString)
        })
        
        return result
    }
    
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func refresh(_ sender: UIRefreshControl) {
        //fetchUsers()
    }
    
    
}

//MARK: - extensions UsersViewController

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = self.getFilteredUsers().count
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCellTableViewCell.reuseId, for: indexPath) as! UserCellTableViewCell
        cell.selectionStyle = .none
        let cellName = getFilteredUsers()[indexPath.row]
        cell.configCell(name: cellName.email!, image: cellName.avatarImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userID = getFilteredUsers()[indexPath.row].id
        let userAvatar = getFilteredUsers()[indexPath.row].avatarImage
        let userName = getFilteredUsers()[indexPath.row].name
        let userMail = getFilteredUsers()[indexPath.row].email
        let vc = ChatViewController()
        vc.otherID = userID
        vc.user.email = userMail
        vc.user.name = userName
        vc.user.avatarImage = userAvatar
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension UsersViewController: UISearchControllerDelegate {
    
}

extension UsersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchString = searchText
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchString = searchBar.text?.lowercased()
    }

}
