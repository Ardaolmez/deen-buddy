//
//  ExploreViewModel.swift
//  Deen Buddy Advanced
//
//  Created by Rana Shaheryar on 10/27/25.
//

import Foundation

final class ExploreViewModel: ObservableObject {
    // could expand later (recent story, featured, etc.)
    @Published private(set) var caliphCount: Int = 4
}
