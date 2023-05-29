//
//  LoginViewController.swift
//  HOLY
//
//  Created by Клим Бакулин on 10.12.2022.
//

import UIKit

protocol LoginViewControllerDelegate{
    func openRegVC()
    func openAuthVC()
    func startApp()
}


class LoginViewController: UIViewController{
    
    var collectionView: UICollectionView!
    var slidesSlider = SliderSlides()
    var slides: [Slides] = []
    var authVC: AuthViewController!
    var regVC: RegViewController!
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = slides.count
        pageControl.currentPageIndicatorTintColor = UIColor.primaryColor
        pageControl.pageIndicatorTintColor = UIColor.secondaryColor
        pageControl.currentPage = 0
        pageControl.backgroundColor = .clear
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCollectionView()
        slides = slidesSlider.getSlides()
        navigationController?.title = nil
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupPageControl()
    }
    
    
    private func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray
        collectionView.isPagingEnabled = true
        
        self.view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.bounces = false // скролл
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.contentInset = .init(top: -20, left: 0, bottom: 0, right: 0)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        collectionView.register(UINib(nibName: SlideCollectionViewCell.reuseId, bundle: nil), forCellWithReuseIdentifier: SlideCollectionViewCell.reuseId)
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    
    
    
    
    
}
//MARK: - Extension LoginViewController

extension LoginViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SlideCollectionViewCell.reuseId, for: indexPath) as! SlideCollectionViewCell
        let slide = slides[indexPath.row]
        cell.configure(slide: slide)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
}

extension LoginViewController: LoginViewControllerDelegate {
    
    func closeVC() {
        if authVC != nil {
            self.navigationController?.popViewController(animated: false)
            authVC = nil
        }
        if regVC != nil {
            self.navigationController?.popViewController(animated: false)
            regVC = nil
        }
    }

    func openAuthVC() {
        if authVC == nil {
            self.authVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        }
        authVC.delegate = self
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    func openRegVC() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegViewController") as? RegViewController else { return }
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true)
        
    }
    
    func startApp() {
        let startVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppViewController")
        guard let window = UIWindow.key else {
            return
        }
        window.rootViewController = startVC
    }
    
}

extension LoginViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
}
