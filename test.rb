# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection
#comp_h = {4769=>{:type=>:double, :adj=>[6369, 4770]}, 4774=>{:type=>:double, :adj=>[6179, 4775]}, 4768=>{:type=>false, :adj=>[]}, 4766=>{:type=>:single, :adj=>[6369]}, 4880=>{:type=>:single, :adj=>[4770]}, 4772=>{:type=>:single, :adj=>[6179]}, 6179=>{:type=>:corner, :adj=>[4774, 4772]}, 6369=>{:type=>:corner, :adj=>[4769, 4766]}, 4775=>{:type=>:single, :adj=>[4774]}, 4770=>{:type=>:double, :adj=>[4769, 4880]}, 9601=>{:type=>false, :adj=>[]}, 9708=>{:type=>false, :adj=>[]}, 9710=>{:type=>false, :adj=>[]}}

#===================================================================
load 'C:/Users/Decorpot-020/Desktop/poc/core.rb'
load 'C:/Users/Decorpot-020/Desktop/poc/working_drawing.rb'
comps 	= DP::get_visible_comps 'right'
comp_h 	= DP::parse_components comps 

#===================================================================
corners = []
comp_h.each_pair{|x, y| corners<<x if y[:type]==:corner}
puts "corners : #{corners}"
corners=[5207,5208,5209,5210]
corners=[5208, 5209]
rows = []
#sel.clear
corners.each{|cor|
    adjs = comp_h[cor][:adj]
	row = []
	puts "adjs : #{adjs}"
    adjs.each{|adj_comp|
		puts "adj_loop : #{adj_comp}"
        row  = [cor]
        curr = adj_comp
        #comp_h[cor][:adj].delete curr
        comp_h[curr][:adj].delete cor
        while comp_h[curr][:type] == :double
            row << curr
            adj_next = comp_h[curr][:adj][0]
			puts "adj : #{curr} : #{adj_next} : #{comp_h}"
            comp_h[adj_next][:adj].delete curr
            comp_h[curr][:adj].delete adj_next
            curr = adj_next
        end
        row << curr
		rows << row
    }
	#rows << row
}


puts "rows--------------------------------------------"
pp rows
puts "------------------------------------------------"

rows.each{|row|
	row.each{|comp|
		Sketchup.active_model.selection.add (DP::get_comp_pid comp)
	}
}
pp comp_h
puts Time.now.strftime("%d/%m/%Y %H:%M")