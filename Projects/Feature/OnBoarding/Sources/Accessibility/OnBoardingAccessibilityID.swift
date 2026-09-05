//
//  OnBoardingAccessibilityID.swift
//  OnBoarding
//

enum OnBoardingAccessibilityID {
  enum Name {
    static let root = "onboarding.name.root"
    static let textField = "onboarding.name.textfield"
    static let nextButton = "onboarding.name.nextbutton"
  }

  enum SelectTeam {
    static let root = "onboarding.selectteam.root"
    static let list = "onboarding.selectteam.list"
    static let skeleton = "onboarding.selectteam.skeleton"
    static let nextButton = "onboarding.selectteam.nextbutton"

    static func item(_ teamID: Int) -> String {
      "onboarding.selectteam.item.\(teamID)"
    }
  }

  enum SelectPart {
    static let root = "onboarding.selectpart.root"
    static let list = "onboarding.selectpart.list"
    static let skeleton = "onboarding.selectpart.skeleton"
    static let nextButton = "onboarding.selectpart.nextbutton"

    static func item(_ jobKeys: String) -> String {
      "onboarding.selectpart.item.\(jobKeys)"
    }
  }

  enum SelectManaging {
    static let root = "onboarding.selectmanaging.root"
    static let list = "onboarding.selectmanaging.list"
    static let skeleton = "onboarding.selectmanaging.skeleton"
    static let nextButton = "onboarding.selectmanaging.nextbutton"

    static func item(_ managingKeys: String) -> String {
      "onboarding.selectmanaging.item.\(managingKeys)"
    }
  }

  enum InviteCode {
    static let root = "onboarding.invitecode.root"
    static let textField = "onboarding.invitecode.textfield"
    static let backButton = "onboarding.invitecode.backbutton"
    static let confirmButton = "onboarding.invitecode.confirmbutton"
  }
}
