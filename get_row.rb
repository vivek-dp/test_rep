# Default code, use or delete...
mod = Sketchup.active_model # Open model
ent = mod.entities # All entities in model
sel = mod.selection # Current selection
inst_arr = Sketchup.active_model.entities.grep(Sketchup::ComponentInstance) 

def get_vector n
	case n
	when 20
		return Geom::Vector3d.new(-1,0,0)
	when 21
		return Geom::Vector3d.new(1,0,0)
	when 22
		return Geom::Vector3d.new(0,-1,0)
	when 23
		return Geom::Vector3d.new(0,1,0)
	end
end

def get_near_comps comp
	puts "comp : #{comp}"
    adj_inst = []
    inst_arr = Sketchup.active_model.entities.grep(Sketchup::ComponentInstance) 
    v1=[];(0..7).each{|x| v1<<(TT::Bounds.point(comp.bounds, x)).to_s}
    #sel.clear
	(20..23).each{|x| 
        pt = TT::Bounds.point(comp.bounds, x)
		res = M.raytest(pt, get_vector(x))
		if res
        #puts "res......"
          #puts x,pt, res[0], pt.distance(res[0]).to_mm
          if pt.distance(res[0]).to_mm > 50
            #puts "inside"
            inst_arr.each do |inst|
              ##puts inst, ins
              next if inst == comp
              bb=inst.bounds.intersect(comp.bounds);
              if bb.empty?
                v2=[];(0..7).each{|x| v2<<(TT::Bounds.point(inst.bounds, x)).to_s}
                adj_inst << inst if (v1&v2).length > 3
              else
                w=bb.width.to_f; h=bb.height.to_f; d=bb.depth.to_f; 
                #if w&&h || w&&d || h&&d
                if [w,h,d].sort.first(2).max > 0
                  #puts "#{w} : #{h} : #{d}"
                  adj_inst << inst 
                end
              end
            end
          else
            adj_inst << res[1][1]
            sel.add(res[1][0]) if res
          end 
        end
	}
    adj_inst.each{|x| sel.add(x)} unless adj_inst.empty?
    adj_inst
end

def add_dim
	row=sel.grep(Sketchup::ComponentInstance)
	gp = Sketchup.active_model.active_entities.add_group(row)
	pt1=gp.bounds.min
	pt2=gp.bounds.max
	pt1.z=0;pt2.z=0;pt2.y=pt1.y;
	dim = Sketchup.active_model.entities.add_dimension_linear(pt1,pt2,dim_vector = Geom::Vector3d.new([0,-10,0]))
	gp.explode
end

adj = get_near_comps fsel
curr = [adj[0]]
end_comp = true
comp_row = [fsel]
while end_comp
	arr = get_near_comps curr[0]
	arr.uniq!
	puts "arr : #{arr}"
	end_comp = false if arr.empty?
	break if arr.empty?
	
	curr = arr - comp_row
	puts "curr : #{curr}"
	comp_row << curr[0]
end
add_dim


