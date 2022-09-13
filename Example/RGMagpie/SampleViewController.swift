//
//  SampleViewController.swift
//  RGMagpie
//
//  Created by Ringo on 09/13/2022.
//  Copyright (c) 2022 Ringo. All rights reserved.
//

import UIKit

final class SampleViewController: UIViewController {
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.rowHeight = 200.0
    tableView.register(
      SampleTableViewCell.self,
      forCellReuseIdentifier: SampleTableViewCell.identifier
    )
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}

// MARK: - DataSource

extension SampleViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return 10
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: SampleTableViewCell.identifier,
      for: indexPath
    ) as? SampleTableViewCell else { return UITableViewCell() }

    cell.setup()

    return cell
  }
}
