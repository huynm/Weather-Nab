# Weather Nab

## NOTE
This project is compatible with Xcode 13.0 (13A233) only. Xcode 12 and Swift verion less than 5.5 does not have automatic Codable conformance for enums with associated values, which will cause compile errors

## Installation
Checkout the repo, open in Xcode, then depends on what you want to do:
- Run the app: select the App target and run (menu Product > Run)
- Run unit test: select the Unit Test target and test (menu Product > Test)
- Run UI test: select the UI Test target and test (menu Product > Test)

## Targets
- App: the main application
- Unit Test: the unit test
- UI Test: the UI test
- UI Test Host: a copy of the App target, used only for UI testing. It has mock for the weather API

## Architecture
The architecture is MVVMC:
- M - Model: simple data structure to hold data
- V - View: presents data to the user
- VM - ViewModel: handles app logic and view states
- C - Coordinator: handles navigation

Other parts that are not mentioned in the architecture's name:
- ViewController: connects data from ViewModel to present it in View, sends inputs from View back to ViewModel, trigger coordinator for navigation
- Repository: provides data, from database or from an API for example

## Folder Structure
- Models: contains models (M in MVVMC)
- ViewModels: contains view models (VM in MVVMC)
- Views: contains views (V in MVVMC)
- Controllers: contains UIViewController subclasses
- Coordinators: contains coordinators (C in MVVM)
- Repositories: contains repositories
- Constants: contains global constants like spacing, accessibility identifiers, ...
- Extensions: contains class and struct extensions
- Resources: contains resources like strings files, json files, asset files, ...

## Libraries
- [RxSwift](https://github.com/ReactiveX/RxSwift): for reactive programming
- [Alamofire](https://github.com/Alamofire/Alamofire): de facto network library for iOS
- [AlamofireNetworkActivityIndicator](https://github.com/Alamofire/AlamofireNetworkActivityIndicator): to show/hide the network activity indicator in the status bar when there's a network request excecuting
- [EasyPeasy](https://github.com/nakiostudio/EasyPeasy): helps with doing auto layout in code. 

Libraries are managed by Swift Package Manager