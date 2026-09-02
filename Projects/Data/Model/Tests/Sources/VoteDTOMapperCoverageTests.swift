import Foundation
import Testing

import Entity
@testable import Model

@Suite("Vote DTO mapper coverage")
struct VoteDTOMapperCoverageTests {
  @Test("투표 관리 DTO는 값과 기본값을 도메인에 반영한다")
  func managementMappers() throws {
    let votes: [VoteListItemDTO] = try decode(#"[{"voteId":7,"title":"팀 투표","status":"OPEN"},{}]"#)
    let mappedVotes = votes.toDomain()
    #expect(mappedVotes[0].id == 7)
    #expect(mappedVotes[0].title == "팀 투표")
    #expect(mappedVotes[1].id == 0)
    #expect(mappedVotes[1].title.isEmpty)

    let detail: VoteDetailDTO = try decode(#"{"voteId":8,"title":"상세","status":"CLOSED"}"#)
    #expect(detail.toDomain().id == 8)
    let emptyDetail: VoteDetailDTO = try decode("{}")
    #expect(emptyDetail.toDomain().title.isEmpty)

    let participation: VoteParticipationDTO = try decode(
      #"{"voteId":9,"status":"OPEN","totalMembers":20,"respondedMembers":12,"participationRate":60}"#
    )
    let participationDomain = participation.toDomain()
    #expect(participationDomain.voteId == 9)
    #expect(participationDomain.totalMembers == 20)
    #expect(participationDomain.respondedMembers == 12)
    #expect(participationDomain.participationRate == 60)
    let emptyParticipation: VoteParticipationDTO = try decode("{}")
    #expect(emptyParticipation.toDomain().totalMembers == 0)

    let responders: NonRespondersDTO = try decode(
      #"{"totalCount":1,"members":[{"memberId":3,"name":"민지","teamName":"iOS 1팀"},{}]}"#
    )
    let nonParticipants = responders.toDomain()
    #expect(nonParticipants[0].id == 3)
    #expect(nonParticipants[0].name == "민지")
    #expect(nonParticipants[1].teamName.isEmpty)
    let emptyResponders: NonRespondersDTO = try decode("{}")
    #expect(emptyResponders.toDomain().isEmpty)
  }

  @Test("팀 투표 템플릿의 중첩 DTO를 도메인으로 변환한다")
  func teamTemplateMapper() throws {
    let dto: TeamVoteTemplateResponseDTO = try decode(
      """
      {
        "templateVersion": 4,
        "status": "OPEN",
        "template": {
          "title": "팀 투표",
          "description": "설명",
          "notice": "공지",
          "categories": [{
            "id": "growth",
            "order": 1,
            "title": "성장",
            "maxSelectableTeams": 2,
            "reasonRequired": true,
            "reasonMinLength": 5,
            "reasonMaxLength": 100,
            "reasonLabel": "선정 이유"
          }]
        },
        "teams": [{"teamId": 10, "name": "iOS 1팀", "serviceName": "출석", "isOwnTeam": true}]
      }
      """
    )

    let domain = dto.toDomain()
    #expect(domain.templateVersion == 4)
    #expect(domain.template.title == "팀 투표")
    #expect(domain.template.categories[0].id == "growth")
    #expect(domain.template.categories[0].reasonRequired)
    #expect(domain.teams[0].id == 10)
    #expect(domain.teams[0].isOwnTeam)

    let empty: TeamVoteTemplateResponseDTO = try decode("{}")
    let defaultDomain = empty.toDomain()
    #expect(defaultDomain.templateVersion == 0)
    #expect(defaultDomain.template.categories.isEmpty)
    #expect(defaultDomain.teams.isEmpty)
  }

  @Test("피드백 질문은 배열과 단일 follow-up 형식을 모두 디코딩한다")
  func feedbackQuestionFollowUpShapes() throws {
    let arrayDTO: FeedbackQuestionDTO = try decode(
      """
      {
        "id":"q1", "order":1, "type":"SINGLE_CHOICE", "title":"만족도", "required":true,
        "maxSelectableOptions":1, "maxLength":20,
        "options":[{"id":"good","label":"좋아요"}],
        "followUp":[{"id":"q2","order":2,"type":"LONG_TEXT","title":"이유","required":false}]
      }
      """
    )
    let arrayDomain = arrayDTO.toDomain()
    #expect(arrayDomain.id == "q1")
    #expect(arrayDomain.options?.first?.label == "좋아요")
    #expect(arrayDomain.followUp.first?.id == "q2")

    let singleDTO: FeedbackQuestionDTO = try decode(
      #"{"id":"q1","followUp":{"id":"q2","title":"추가 질문"}}"#
    )
    #expect(singleDTO.followUp?.count == 1)
    #expect(singleDTO.toDomain().followUp.first?.title == "추가 질문")

    let invalidDTO: FeedbackQuestionDTO = try decode(#"{"id":"q1","followUp":123}"#)
    #expect(invalidDTO.followUp == nil)
    #expect(invalidDTO.toDomain().followUp.isEmpty)
  }

  @Test("피드백 템플릿 응답은 값과 누락 기본값을 변환한다")
  func feedbackTemplateMapper() throws {
    let dto: FeedbackTemplateResponseDTO = try decode(
      """
      {
        "templateVersion":2,
        "status":"OPEN",
        "template":{
          "title":"회고", "description":"피드백",
          "questions":[{"id":"q1","order":1,"type":"BOOLEAN","title":"추천","required":true}]
        }
      }
      """
    )
    let domain = dto.toDomain()
    #expect(domain.templateVersion == 2)
    #expect(domain.template.questions.first?.id == "q1")

    let empty: FeedbackTemplateResponseDTO = try decode("{}")
    #expect(empty.toDomain().template.questions.isEmpty)
  }

  @Test("팀 투표 결과의 순위와 사유를 중첩 변환한다")
  func teamVoteResultsMapper() throws {
    let dto: TeamVoteResultsDTO = try decode(
      """
      {
        "voteId":31,"title":"결과","status":"CLOSED","totalResponses":14,
        "categories":[{
          "categoryId":"impact","title":"임팩트","order":1,"reasons":["좋은 영향"],
          "teams":[{"rank":1,"teamId":5,"name":"iOS","serviceName":"출석","voteCount":9}]
        }]
      }
      """
    )
    let domain = dto.toDomain()
    #expect(domain.voteId == 31)
    #expect(domain.totalResponses == 14)
    #expect(domain.categories[0].teams[0].rank == 1)
    #expect(domain.categories[0].teams[0].voteCount == 9)
    #expect(domain.categories[0].reasons == ["좋은 영향"])

    let empty: TeamVoteResultsDTO = try decode("{}")
    #expect(empty.toDomain().categories.isEmpty)
  }

  @Test("피드백 결과의 선택지, 불리언, 텍스트 응답을 변환한다")
  func feedbackResultsMapper() throws {
    let dto: FeedbackResultsDTO = try decode(
      """
      {
        "voteId":41,"totalResponses":8,
        "questions":[{
          "questionId":"q1","title":"만족도","type":"SINGLE_CHOICE","order":1,
          "options":[{"optionId":"good","label":"좋아요","count":6}],
          "trueCount":7,"falseCount":1,"textAnswers":["좋았습니다"]
        }]
      }
      """
    )
    let domain = dto.toDomain()
    #expect(domain.voteId == 41)
    #expect(domain.questions[0].options?[0].id == "good")
    #expect(domain.questions[0].trueCount == 7)
    #expect(domain.questions[0].textAnswers == ["좋았습니다"])

    let invalidType: FeedbackResultsDTO = try decode(
      #"{"questions":[{"type":"UNKNOWN","options":[{}]}]}"#
    )
    let fallback = invalidType.toDomain().questions[0]
    #expect(fallback.id.isEmpty)
    #expect(fallback.options?[0].count == 0)
  }

  @Test("활성 투표와 내 응답 DTO는 누락 값도 안전하게 변환한다")
  func memberVoteMappers() throws {
    let active: ActiveVoteDTO = try decode(#"{"voteId":51,"title":"진행 중","alreadyResponded":true}"#)
    #expect(active.toDomain().alreadyResponded)
    let emptyActive: ActiveVoteDTO = try decode("{}")
    #expect(emptyActive.toDomain().voteId == 0)

    let mine: MyVoteResponseDTO = try decode(#"{"voteId":51,"responded":true}"#)
    #expect(mine.toDomain().responded)
    let emptyMine: MyVoteResponseDTO = try decode("{}")
    #expect(emptyMine.toDomain().responded == false)
  }
}

private func decode<T: Decodable>(_ json: String) throws -> T {
  try JSONDecoder().decode(T.self, from: Data(json.utf8))
}
