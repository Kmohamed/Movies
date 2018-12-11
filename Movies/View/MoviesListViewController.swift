//
//  MoviesListViewController.swift
//  Movies
//
//  Created by khaled mohamed el morabea on 12/11/18.
//  Copyright © 2018 Instabug. All rights reserved.
//

import UIKit

class MoviesListViewController: UIViewController {

    @IBOutlet weak var moviesTableView: UITableView!
    private var moviesListPresnter: MoviesListPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.moviesListPresnter = self.moviesPresenter()
        self.moviesListPresnter?.delegate = self
        self.moviesListPresnter?.fetchMovies()
        // Do any additional setup after loading the view.
    }
    
    
    func moviesPresenter() -> MoviesListPresenter {
        let networkLayer = Network()
        let moviesModel = MoviesListModel(networkLayer: networkLayer)
        let moviesListPresnter = MoviesListPresenter(moviesListModel: moviesModel)
        
        return moviesListPresnter
    }
}

extension MoviesListViewController: MoviesListPresenterDelegate {
    func didFetchMovies(success: Bool) {
        DispatchQueue.main.async {
            self.moviesTableView.reloadData()
        }
    }
}

extension MoviesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.moviesListPresnter?.moviesCount())!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        cell?.textLabel?.text = self.moviesListPresnter?.movieName(index: indexPath.row)
        cell?.detailTextLabel?.text = self.moviesListPresnter?.movieRatting(index: indexPath.row)
        return cell!
    }
    
    
}
