def create_nfl
  @afc = create_section(:parent => root_section, :name => "AFC")

  @afc_east = create_section(:parent => @afc, :name => "East")
  @buf = create_page(:section => @afc_east, :name => "Buffalo Bills", :path => "/buf")
  @mia = create_page(:section => @afc_east, :name => "Miami Dolphins", :path => "/mia")
  @ne = create_page(:section => @afc_east, :name => "New England Patriots", :path => "/ne")
  @nyj = create_page(:section => @afc_east, :name => "New York Jets", :path => "/nyj")

  @afc_north = create_section(:parent => @afc, :name => "North")
  @bal = create_page(:section => @afc_north, :name => "Baltimore Ravens", :path => "/bal")
  @cin = create_page(:section => @afc_north, :name => "Cincinnati Bengals", :path => "/cin")
  @cle = create_page(:section => @afc_north, :name => "Cleveland Browns", :path => "/cle")
  @pit = create_page(:section => @afc_north, :name => "Pittsburgh Steelers", :path => "/pit")

  @afc_south = create_section(:parent => @afc, :name => "South")
  @hou = create_page(:section => @afc_south, :name => "Houston Texans", :path => "/hou")
  @ind = create_page(:section => @afc_south, :name => "Indianapolis Colts", :path => "/ind")
  @jac = create_page(:section => @afc_south, :name => "Jacksonville Jaguars", :path => "/jac")
  @ten = create_page(:section => @afc_south, :name => "Tennessee Titans", :path => "/ten")

  @afc_west = create_section(:parent => @afc, :name => "West")
  @den = create_page(:section => @afc_west, :name => "Denver Broncos", :path => "/den")
  @kc = create_page(:section => @afc_west, :name => "Kansas City Chiefs", :path => "/kc")
  @oak = create_page(:section => @afc_west, :name => "Oakland Raiders", :path => "/oak")
  @sd = create_page(:section => @afc_west, :name => "San Diego Chargers", :path => "/sd")

  @nfc = create_section(:parent => root_section, :name => "NFC")

  @nfc_east = create_section(:parent => @nfc, :name => "East")
  @dal = create_page(:section => @nfc_east, :name => "Dallas Cowboys", :path => "/dal")
  @nyg = create_page(:section => @nfc_east, :name => "New York Giants", :path => "/nyg")
  @phi = create_page(:section => @nfc_east, :name => "Philadelphia Eagles", :path => "/phi")
  @was = create_page(:section => @nfc_east, :name => "Washington Redskins", :path => "/was")

  @nfc_north = create_section(:parent => @nfc, :name => "North")
  @chi = create_page(:section => @nfc_north, :name => "Chicago Bears", :path => "/chi")
  @det = create_page(:section => @nfc_north, :name => "Detroit Lions", :path => "/det")
  @gb = create_page(:section => @nfc_north, :name => "Green Bay Packers", :path => "/gb")
  @min = create_page(:section => @nfc_north, :name => "Minnesota Vikings", :path => "/min")

  @nfc_south = create_section(:parent => @nfc, :name => "South")
  @atl = create_page(:section => @nfc_south, :name => "Atlanta Falcons", :path => "/atl")
  @car = create_page(:section => @nfc_south, :name => "Carolina Pathers", :path => "/car")
  @no = create_page(:section => @nfc_south, :name => "New Orleans Saints", :path => "/no")
  @tb = create_page(:section => @nfc_south, :name => "Tampa Bay Buccaneers", :path => "/tb")

  @nfc_west = create_section(:parent => @nfc, :name => "West")
  @ari = create_page(:section => @nfc_west, :name => "Arizona Cardinals", :path => "/ari")
  @sf = create_page(:section => @nfc_west, :name => "San Francisco 49ers", :path => "/sf")
  @sea = create_page(:section => @nfc_west, :name => "Seattle Seahawks", :path => "/sea")
  @stl = create_page(:section => @nfc_west, :name => "St. Louis Rams", :path => "/stl")
  
end
