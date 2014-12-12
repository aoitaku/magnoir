module SceneManager

  def self.run(scene_class)
    scene = scene_class.new
    Window.loop do
      scene.update
      scene.render
      if scene.next_scene
        scene.quit
        break if Scene::Exit == scene.next_scene
        scene = scene.next_scene.new
      end
    end
  end

end
