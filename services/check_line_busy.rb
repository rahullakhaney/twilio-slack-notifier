# frozen_string_literal: true

class CheckLineBusy
  attr_reader :client

  def initialize(client:)
    @client = client
  end

  def call
    line_busy?
  end

  private

  def line_busy?
    return false unless find_in_progress_conference
    check_current_conference_participants
  end

  def check_current_conference_participants
    participants = conference_participants
    participants.list.count == 2
  end

  def find_in_progress_conference
    conferences = fetch_client_conferences
    conferences.list(status: 'in-progress').first
  end

  def conference_participants
    in_progress_conference = find_in_progress_conference
    in_progress_conference.participants
  end

  def fetch_client_conferences
    account = client_account
    account.conferences
  end

  def client_account
    client.account
  end
end
