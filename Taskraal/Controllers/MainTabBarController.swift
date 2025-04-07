//
//  MainTabBarController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    private var neumorphicBackgroundColor: UIColor {
        return ThemeManager.shared.backgroundColor
    }
    private var accentColor: UIColor {
        return ThemeManager.shared.currentThemeColor
    }
    private let unselectedColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
    private let themeManager = ThemeManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBar()
        setupNotificationObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicEffect()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    func setupTabs() {
        let tasksVC = TasksViewController()
        let categoriesVC = CategoriesViewController()
        let settingsVC = SettingsViewController()
        
        // Configure each view controller
        configureController(tasksVC, title: "Tasks", navBarColor: neumorphicBackgroundColor)
        configureController(categoriesVC, title: "Categories", navBarColor: neumorphicBackgroundColor)
        configureController(settingsVC, title: "Settings", navBarColor: neumorphicBackgroundColor)
        
        // Create navigation controllers
        let tasksNavController = createNavController(for: tasksVC, title: "Tasks",
                                                    image: "checklist", selectedImage: "checklist.fill")
        let categoriesNavController = createNavController(for: categoriesVC, title: "Categories",
                                                         image: "folder", selectedImage: "folder.fill")
        let settingsNavController = createNavController(for: settingsVC, title: "Settings",
                                                       image: "gear", selectedImage: "gear.fill")
        
        setViewControllers([tasksNavController, categoriesNavController, settingsNavController], animated: true)
    }
    
    private func configureController(_ viewController: UIViewController, title: String, navBarColor: UIColor) {
        viewController.title = title
        viewController.view.backgroundColor = neumorphicBackgroundColor
    }
    
    private func createNavController(for rootViewController: UIViewController, title: String,
                                    image: String, selectedImage: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        // Configure navigation bar appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeManager.backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1.0)]
            appearance.shadowColor = .clear // Remove navigation bar shadow
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navController.navigationBar.barTintColor = themeManager.backgroundColor
            navController.navigationBar.tintColor = themeManager.currentThemeColor
            navController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1.0)]
            navController.navigationBar.shadowImage = UIImage() // Remove navigation bar shadow
        }
        
        // Configure tab bar item
        navController.tabBarItem = UITabBarItem(title: title,
                                              image: UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate),
                                              selectedImage: UIImage(systemName: selectedImage)?.withRenderingMode(.alwaysTemplate))
        
        return navController
    }
    
    private func customizeTabBar() {
        // Set tab bar's background color
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        // Set icon colors - use direct color reference for better performance
        tabBar.tintColor = themeManager.currentThemeColor
        tabBar.unselectedItemTintColor = unselectedColor
        
        // Modern appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Set icon colors with direct color reference
            appearance.stackedLayoutAppearance.selected.iconColor = themeManager.currentThemeColor
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            
            // Set text colors with direct color reference
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeManager.currentThemeColor]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func applyNeumorphicEffect() {
        guard let tabBarSuperview = tabBar.superview else { return }
        
        // Remove any existing effect view
        tabBarSuperview.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        
        // Create the neo-neumorphic container
        let container = UIView()
        container.tag = 999
        container.backgroundColor = themeManager.tabBarBackgroundColor
        
        // Make it slightly larger than the tab bar with rounded corners at the top
        container.frame = CGRect(x: 8,
                               y: tabBar.frame.origin.y - 10,
                               width: tabBar.frame.width - 16,
                               height: tabBar.frame.height + 10)
        
        // Add rounded corners
        container.layer.cornerRadius = 25
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
        
        // Create subtle inner shadow effect - adapted for dark mode but simplified
        if themeManager.isDarkModeEnabled {
            // Darker shadow for dark mode - simplified
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowOpacity = 0.7
            container.layer.shadowRadius = 6
            
            // Add inner glow for dark mode - simplified dark gray highlight
            let innerShadow = CALayer()
            innerShadow.frame = container.bounds.insetBy(dx: 2, dy: 2)
            innerShadow.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0).cgColor
            innerShadow.cornerRadius = 23
            container.layer.addSublayer(innerShadow)
        } else {
            // Light mode shadows - simplified
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowOpacity = 0.08
            container.layer.shadowRadius = 6
            
            // Create light highlight at the top - use a simpler approach 
            let topHighlight = UIView()
            topHighlight.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: 1)
            topHighlight.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            container.addSubview(topHighlight)
        }
        
        // Create a subtle line above the tab bar for separation - simplified
        let separatorView = UIView()
        separatorView.frame = CGRect(x: 25,
                                    y: 12,
                                    width: container.frame.width - 50,
                                    height: 4)
        separatorView.backgroundColor = themeManager.isDarkModeEnabled ? 
            UIColor.darkGray.withAlphaComponent(0.5) : 
            unselectedColor.withAlphaComponent(0.2)
        separatorView.layer.cornerRadius = 2
        container.addSubview(separatorView)
        
        // Add small indicator lights for selected tab - simplified
        for i in 0...2 {
            let indicatorLight = UIView()
            indicatorLight.frame = CGRect(x: (container.frame.width / 3) * CGFloat(i) + (container.frame.width / 6) - 3,
                                        y: 12,
                                        width: 6,
                                        height: 6)
            indicatorLight.layer.cornerRadius = 3
            indicatorLight.backgroundColor = i == selectedIndex ? themeManager.currentThemeColor : .clear
            indicatorLight.tag = 1000 + i
            container.addSubview(indicatorLight)
        }
        
        // Insert behind tab bar
        tabBarSuperview.insertSubview(container, belowSubview: tabBar)
    }
    
    // MARK: - Tab Selection
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Update indicator lights with animation
        if let container = view.viewWithTag(999) {
            // Batch update indicators
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                for i in 0...2 {
                    if let indicator = container.viewWithTag(1000 + i) {
                        // Only animate the selected indicator
                        if i == self.selectedIndex {
                            indicator.backgroundColor = self.themeManager.currentThemeColor
                            indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                                indicator.transform = .identity
                            }, completion: nil)
                        } else {
                            indicator.backgroundColor = .clear
                        }
                    }
                }
            }, completion: nil)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: NSNotification.Name("AppThemeChanged"),
            object: nil
        )
    }
    
    @objc private func handleThemeChanged() {
        // Update the tab bar tint immediately
        tabBar.tintColor = themeManager.currentThemeColor
        
        // Force the current tab item to refresh its tint
        if let items = tabBar.items, selectedIndex < items.count {
            let currentItem = items[selectedIndex]
            currentItem.setTitleTextAttributes([.foregroundColor: themeManager.currentThemeColor], for: .selected)
        }
        
        // Update iOS 15+ appearance if needed
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            appearance.stackedLayoutAppearance.selected.iconColor = themeManager.currentThemeColor
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: themeManager.currentThemeColor]
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // Update the navigation bar tint colors for each tab
        viewControllers?.forEach { navController in
            if let nav = navController as? UINavigationController {
                nav.navigationBar.tintColor = themeManager.currentThemeColor
            }
        }
        
        // Remove existing neumorphic container before creating a new one
        if let tabBarSuperview = tabBar.superview {
            tabBarSuperview.subviews.forEach { subview in
                if subview.tag == 999 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // Reapply the neumorphic effect with the new theme
        applyNeumorphicEffect()
    }
}
