//
//  ClipCookTests.swift
//  ClipCookTests
//
//  Created by Ramon Smeekens on 12/02/2026.
//

import Testing
@testable import ClipCook

// MARK: - Apple Sign In Helper Tests

struct AppleSignInHelperTests {

    @Test func nonceHasCorrectLength() {
        let nonce = AppleSignInHelper.randomNonceString(length: 32)
        #expect(nonce.count == 32)
    }

    @Test func nonceWithCustomLength() {
        let nonce = AppleSignInHelper.randomNonceString(length: 64)
        #expect(nonce.count == 64)
    }

    @Test func nonceContainsOnlyValidCharacters() {
        let validChars = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = AppleSignInHelper.randomNonceString(length: 100)
        for char in nonce {
            #expect(validChars.contains(char), "Unexpected character: \(char)")
        }
    }

    @Test func noncesAreUnique() {
        let nonce1 = AppleSignInHelper.randomNonceString()
        let nonce2 = AppleSignInHelper.randomNonceString()
        #expect(nonce1 != nonce2)
    }

    @Test func sha256ProducesConsistentHash() {
        let hash1 = AppleSignInHelper.sha256("test")
        let hash2 = AppleSignInHelper.sha256("test")
        #expect(hash1 == hash2)
    }

    @Test func sha256ProducesCorrectLength() {
        let hash = AppleSignInHelper.sha256("test")
        // SHA256 produces 64 hex characters
        #expect(hash.count == 64)
    }

    @Test func sha256DifferentInputsDifferentHashes() {
        let hash1 = AppleSignInHelper.sha256("hello")
        let hash2 = AppleSignInHelper.sha256("world")
        #expect(hash1 != hash2)
    }
}

// MARK: - Import ViewModel Tests

struct ImportViewModelTests {

    @Test func detectInstagramSource() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://www.instagram.com/reel/ABC123/")
        #expect(sourceType == .instagram)
    }

    @Test func detectTikTokSource() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://www.tiktok.com/@user/video/123")
        #expect(sourceType == .tiktok)
    }

    @Test func detectYouTubeSource() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://www.youtube.com/watch?v=ABC123")
        #expect(sourceType == .youtube)
    }

    @Test func detectYouTuBeShortLink() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://youtu.be/ABC123")
        #expect(sourceType == .youtube)
    }

    @Test func detectWebSource() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://www.allerhande.nl/recept/123")
        #expect(sourceType == .web)
    }

    @Test func detectSourceCaseInsensitive() {
        let viewModel = ImportViewModel()
        let sourceType = viewModel.detectSourceType(from: "https://WWW.INSTAGRAM.COM/p/ABC/")
        #expect(sourceType == .instagram)
    }

    @Test func createRecipeFromImport() {
        let viewModel = ImportViewModel()
        viewModel.urlString = "https://instagram.com/reel/123"
        viewModel.fetchedTitle = "Pasta Carbonara"
        viewModel.fetchedDescription = "Een heerlijk recept"
        viewModel.detectedSourceType = .instagram

        let recipe = viewModel.createRecipe()

        #expect(recipe.title == "Pasta Carbonara")
        #expect(recipe.sourceURL == "https://instagram.com/reel/123")
        #expect(recipe.sourceType == .instagram)
        #expect(recipe.notes == "Een heerlijk recept")
    }

    @Test func createRecipeWithDefaultTitle() {
        let viewModel = ImportViewModel()
        viewModel.urlString = "https://example.com"
        viewModel.fetchedTitle = nil
        viewModel.detectedSourceType = .web

        let recipe = viewModel.createRecipe()

        #expect(recipe.title == "Nieuw recept")
    }

    @Test func resetClearsAllFields() {
        let viewModel = ImportViewModel()
        viewModel.urlString = "https://test.com"
        viewModel.fetchedTitle = "Test"
        viewModel.fetchedDescription = "Description"
        viewModel.detectedSourceType = .instagram
        viewModel.errorMessage = "Error"

        viewModel.reset()

        #expect(viewModel.urlString == "")
        #expect(viewModel.fetchedTitle == nil)
        #expect(viewModel.fetchedDescription == nil)
        #expect(viewModel.detectedSourceType == .web)
        #expect(viewModel.errorMessage == nil)
    }
}
