@testable import Mmp2
import Testing

@MainActor
@Suite("Home navigation")
struct HomeNavigationTests {
    @Test
    func categoryChangesClearEditorPathButReselectingDoesNot() {
        let manager = AppRootManager.shared
        let originalCategory = manager.selectedCategory
        let originalPath = manager.detailPath
        defer {
            manager.selectedCategory = originalCategory
            manager.detailPath = originalPath
        }

        manager.selectedCategory = .collections
        manager.editCollection(MediaCollection.makeDraft())
        #expect(manager.detailPath.count == 1)

        manager.selectedCategory = .collections
        #expect(manager.detailPath.count == 1)

        manager.selectedCategory = .playlists
        #expect(manager.detailPath.isEmpty)
    }
}
